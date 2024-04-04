//
//  LocationService.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/2/24.

import CoreLocation
import Firebase
import Foundation
import Spezi

public class LocationModule: NSObject, CLLocationManagerDelegate, Module, DefaultInitializable, EnvironmentAccessible {
    private(set) var manager = CLLocationManager()
    public var allLocations = [CLLocationCoordinate2D]()
    public var onLocationsUpdated: (([CLLocationCoordinate2D]) -> Void)?

    private var previousLocation: CLLocationCoordinate2D?
    private var previousDate: Date?

    @Published var authorizationStatus: CLAuthorizationStatus = CLLocationManager().authorizationStatus
    @Published var canShowRequestMessage = true

    private var lastKnownLocation: CLLocationCoordinate2D? {
        didSet {
            guard let lastKnownLocation = lastKnownLocation else {
                return
            }
            self.appendNewLocationPoint(point: lastKnownLocation)
        }
    }

    override public required init() {
        super.init()
        manager.delegate = self

        // If user doesn't have a tracking preference, default to true
        if UserDefaults.standard.value(forKey: Constants.prefTrackingStatus) == nil {
            UserDefaults.standard.set(true, forKey: Constants.prefTrackingStatus)
        }

        // If tracking status is true, start tracking
        if UserDefaults.standard.bool(forKey: Constants.prefTrackingStatus) {
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
            print("[LIFESPACE] Starting tracking...")
        } else {
            print("[LIFESPACE] Cannot start tracking - location services are not enabled.")
        }
    }

    public func stopTracking() {
        self.manager.stopUpdatingLocation()
        self.manager.stopMonitoringSignificantLocationChanges()
        print("[LIFESPACE] Stopping tracking...")
    }

    public func requestAuthorizationLocation() {
        self.manager.requestWhenInUseAuthorization()
        self.manager.requestAlwaysAuthorization()
    }

    /// Get all the points for a particular date from the database
    /// - Parameter date: the date for which to fetch all points
    func fetchPoints(date: Date = Date()) {
        // TODO: Fetch from Firestore
    }

    /// Adds a new point to the map and saves the location to the database,
    /// if it meets the criteria to be added.
    /// - Parameter point: the point to add
    private func appendNewLocationPoint(point: CLLocationCoordinate2D) {
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
                add = true
                fetchPoints()
            }
        }

        if add {
            // update local location data for map
            allLocations.append(point)
            onLocationsUpdated?(allLocations)
            previousLocation = point
            previousDate = Date()

            // TODO: Save to Firestore
        }
    }

    public func userAuthorizeAlways() -> Bool {
        self.manager.authorizationStatus == .authorizedAlways
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // An additional check that we only append points if location tracking is turned on
        guard UserDefaults.standard.bool(forKey: Constants.prefTrackingStatus) else {
            return
        }

        lastKnownLocation = locations.first?.coordinate
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
