//
//  LocationStorage.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 12/28/24.
//

import CoreLocation

internal actor LocationStorage {
    var allLocations: [CLLocationCoordinate2D]
    var lastSaved: (location: CLLocationCoordinate2D, date: Date)?
    
    init() {
        self.allLocations = []
    }
    
    func updateLocations(_ locations: [CLLocationCoordinate2D]) {
        self.allLocations = locations
    }
    
    func appendLocation(_ coordinate: CLLocationCoordinate2D) {
        self.allLocations.append(coordinate)
    }
    
    func getLastSaved() -> (location: CLLocationCoordinate2D, date: Date)? {
        lastSaved
    }
    
    func updateLastSaved(location: CLLocationCoordinate2D, date: Date) {
        self.lastSaved = (location: location, date: date)
    }
    
    func getAllLocations() -> [CLLocationCoordinate2D] {
        allLocations
    }
    
    func clearLocations() {
        allLocations.removeAll()
    }
}
