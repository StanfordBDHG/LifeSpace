//
//  LocationStorage.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 12/28/24.
//

import CoreLocation

/// An actor that manages storage and retrieval of location coordinates.
/// This class provides thread-safe access to location data and maintains both a collection
/// of locations and information about the last saved location.
actor LocationStorage {
    /// Array storing all recorded location coordinates
    private var allLocations: [CLLocationCoordinate2D]
    
    /// Tuple containing the most recently saved location and its timestamp.
    /// We use this in `LocationModule` to handle daily location resets.
    private var lastSaved: (location: CLLocationCoordinate2D, date: Date)?
    
    init() {
        self.allLocations = []
    }
    
    /// Adds a new location coordinate to the collection
    /// - Parameter coordinate: The location coordinate to append
    func appendLocation(_ coordinate: CLLocationCoordinate2D) {
        self.allLocations.append(coordinate)
    }
    
    /// Updates the entire collection of locations with a new array
        /// - Parameter locations: Array of coordinates to replace the existing locations
    func updateAllLocations(_ locations: [CLLocationCoordinate2D]) {
        self.allLocations = locations
    }
    
    /// Retrieves all stored location coordinates
    /// - Returns: Array of all stored location coordinates
    func getAllLocations() -> [CLLocationCoordinate2D] {
        allLocations
    }
    
    /// Removes all stored locations from the collection
    func clearAllLocations() {
        allLocations.removeAll()
    }
    
    /// Retrieves the most recently saved location and its timestamp
    /// - Returns: Tuple containing the location coordinate and save date, or nil if no location has been saved
    func getLastSaved() -> (location: CLLocationCoordinate2D, date: Date)? {
        lastSaved
    }
    
    /// Updates the most recently saved location with a new coordinate and timestamp
    /// - Parameters:
    ///   - location: The location coordinate to save
    ///   - date: The timestamp of when the location was saved
    func updateLastSaved(location: CLLocationCoordinate2D, date: Date) {
        self.lastSaved = (location: location, date: date)
    }
}
