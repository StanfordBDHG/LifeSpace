//
//  LocationModule.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/2/24.

import CoreLocation
import Firebase
import Foundation
import OSLog
import Spezi

public class LocationModule: NSObject, CLLocationManagerDelegate, Module, DefaultInitializable, EnvironmentAccessible {
    @Dependency private var standard: LifeSpaceStandard?
    
    private(set) var manager = CLLocationManager()
    public var allLocations = [CLLocationCoordinate2D]()
    public var onLocationsUpdated: (([CLLocationCoordinate2D]) -> Void)?
    private let logger = Logger(subsystem: "LifeSpace", category: "Standard")

    private var previousLocation: CLLocationCoordinate2D?
    private var previousDate: Date?

    @Published var authorizationStatus = CLLocationManager().authorizationStatus
    @Published var canShowRequestMessage = true

    private var lastKnownLocation: CLLocationCoordinate2D? {
        didSet {
            guard let lastKnownLocation = lastKnownLocation else {
                return
            }
            Task {
                await self.appendNewLocationPoint(point: lastKnownLocation)
            }
        }
    }

    override public required init() {
        super.init()
        manager.delegate = self

        // If user doesn't have a tracking preference, default to true
        if UserDefaults.standard.value(forKey: StorageKeys.trackingPreference) == nil {
            UserDefaults.standard.set(true, forKey: StorageKeys.trackingPreference)
        }

        // If tracking status is true, start tracking
        if UserDefaults.standard.bool(forKey: StorageKeys.trackingPreference) {
            self.startTracking()
        }
        
        // Disable Mapbox telemetry
        UserDefaults.standard.set(false, forKey: "MGLMapboxMetricsEnabled")
    }

    public func startTracking() {
        if CLLocationManager.locationServicesEnabled() {
            self.manager.startUpdatingLocation()
            self.manager.startMonitoringSignificantLocationChanges()
            self.manager.allowsBackgroundLocationUpdates = true
            self.manager.pausesLocationUpdatesAutomatically = false
            self.manager.showsBackgroundLocationIndicator = false
            logger.info("Starting tracking...")
        } else {
            logger.error("Cannot start tracking - location services are not enabled.")
        }
    }

    public func stopTracking() {
        self.manager.stopUpdatingLocation()
        self.manager.stopMonitoringSignificantLocationChanges()
        logger.info("Stopping tracking...")
    }
    

    public func requestAuthorizationLocation() {
        self.manager.requestWhenInUseAuthorization()
        self.manager.requestAlwaysAuthorization()
    }

    public func fetchLocations() async {
        do {
            if let locations = try await standard?.fetchLocations() {
                self.allLocations = locations
                self.onLocationsUpdated?(self.allLocations)
            }
        } catch {
            logger.error("Error fetching locations: \(error.localizedDescription)")
        }
    }

    /// Adds a new point to the map and saves the location to the database,
    /// if it meets the criteria to be added.
    /// - Parameter point: the point to add
    private func appendNewLocationPoint(point: CLLocationCoordinate2D) async {
        // Check that we only append points if location tracking is turned on
        guard UserDefaults.standard.bool(forKey: StorageKeys.trackingPreference) else {
            return
        }
        
        var add = true

        if let previousLocation = previousLocation,
           let previousDate = previousDate {
            // Check if distance between current point and previous point is greater than the minimum
            add = LocationUtils.isAboveMinimumDistance(
                previousLocation: previousLocation,
                currentLocation: point
            )

            // Reset all points when day changes
            if Date().startOfDay != previousDate.startOfDay {
                await fetchLocations()
                add = true
            }
        }

        if add {
            // update local location data for map
            allLocations.append(point)
            onLocationsUpdated?(allLocations)
            previousLocation = point
            previousDate = Date()
            
            do {
                try await standard?.add(location: point)
            } catch {
                logger.error("Error adding location: \(error.localizedDescription)")
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Check that we only append points if location tracking is turned on
        guard UserDefaults.standard.bool(forKey: StorageKeys.trackingPreference) else {
            return
        }

        lastKnownLocation = locations.first?.coordinate
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
