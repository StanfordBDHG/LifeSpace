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
    private let logger = Logger(subsystem: "LifeSpace", category: "Standard")
    private(set) var manager = CLLocationManager()
    
    @Published var authorizationStatus = CLLocationManager().authorizationStatus
    @Published var canShowRequestMessage = true
    
    public var allLocations = [CLLocationCoordinate2D]()
    public var onLocationsUpdated: (([CLLocationCoordinate2D]) -> Void)?
    private var lastSaved: (location: CLLocationCoordinate2D, date: Date)?

    override public required init() {
        super.init()
        manager.delegate = self

        /// If `trackingPreference` is set to true, we can start tracking.
        if UserDefaults.standard.bool(forKey: StorageKeys.trackingPreference) {
            self.startTracking()
        }
        
        /// Disable Mapbox telemetry as required by the study protocol.
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
        self.manager.allowsBackgroundLocationUpdates = false
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
    
    /// Adds a new coordinate to the map and database,
    /// - Parameter coordinate: the new coordinate to add.
    @MainActor
    private func appendNewLocation(_ coordinate: CLLocationCoordinate2D) async {
        let shouldAddLocation = await determineIfShouldAddLocation(coordinate)
        
        if shouldAddLocation {
            updateLocalLocations(with: coordinate)
            await saveLocation(coordinate)
        }
    }
    
    /// Determines if a location meets the criteria to be saved.
    /// - Parameter coordinate: The `CLLocationCoordinate2D` of the location to be saved.
    private func determineIfShouldAddLocation(_ coordinate: CLLocationCoordinate2D) async -> Bool {
        /// Check if the user has set tracking `on` before adding the new location.
        guard UserDefaults.standard.bool(forKey: StorageKeys.trackingPreference) else {
            return false
        }
        
        /// Check if there is a previously saved point, so we can calculate the distance between that and the current point.
        /// If there's no previously saved point, we can save the current point
        guard let lastSaved else {
            return true
        }
        
        /// Check if the date of the current point is a different day then the last saved point. If so,
        /// Refresh the locations array and save this point.
        if Date().startOfDay != lastSaved.date.startOfDay {
            await fetchLocations()
            return true
        }
        
        return LocationUtils.isAboveMinimumDistance(
            previousLocation: lastSaved.location,
            currentLocation: coordinate
        )
    }
    
    /// Updates the local set of locations and the map with the latest location
    /// - Parameter coordinate: The `CLLocationCoordinate2D` of the location to be saved.
    private func updateLocalLocations(with coordinate: CLLocationCoordinate2D) {
        allLocations.append(coordinate)
        onLocationsUpdated?(allLocations)
        lastSaved = (location: coordinate, date: Date())
    }
    
    /// Saves a location to Firestore via the Standard.
    /// - Parameter coordinate: the `CLLocationCoordinate2D` of the location to be saved.
    private func saveLocation(_ coordinate: CLLocationCoordinate2D) async {
        do {
            try await standard?.add(location: coordinate)
        } catch {
            logger.error("Error saving location: \(error.localizedDescription)")
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first?.coordinate else {
            return
        }
        Task {
            await appendNewLocation(latestLocation)
        }
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
