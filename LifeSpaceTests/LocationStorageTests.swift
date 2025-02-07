//
//  LocationStorageTests.swift
//  LifeSpaceTests
//
//  Created by Vishnu Ravi on 2/7/25.
//

import CoreLocation
@testable import LifeSpace
import XCTest

final class LocationStorageTests: XCTestCase {
    var locationStorage: LocationStorage?
    
    override func setUp() async throws {
        locationStorage = LocationStorage()
    }
    
    override func tearDown() async throws {
        locationStorage = nil
    }
    
    func testInitialState() async {
        guard let locationStorage else {
            XCTFail("LocationStorage should be initialized")
            return
        }
        
        let locations = await locationStorage.getAllLocations()
        XCTAssertTrue(locations.isEmpty, "Initial locations array should be empty")
        
        let lastSaved = await locationStorage.getLastSaved()
        XCTAssertNil(lastSaved, "Initial lastSaved should be nil")
    }
    
    func testAppendLocation() async {
        guard let locationStorage else {
            XCTFail("LocationStorage should be initialized")
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        await locationStorage.appendLocation(coordinate)
        
        let locations = await locationStorage.getAllLocations()
        XCTAssertEqual(locations.count, 1, "Should have one location after append")
        
        guard let firstLocation = locations.first else {
            XCTFail("Location should exist")
            return
        }
        
        XCTAssertEqual(firstLocation.latitude, coordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(firstLocation.longitude, coordinate.longitude, accuracy: 0.0001)
    }
    
    func testUpdateAllLocations() async {
        guard let locationStorage else {
            XCTFail("LocationStorage should be initialized")
            return
        }
        
        let coordinates = [
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        ]
        
        await locationStorage.updateAllLocations(coordinates)
        let locations = await locationStorage.getAllLocations()
        
        XCTAssertEqual(locations.count, coordinates.count)
        
        for (index, stored) in locations.enumerated() {
            let original = coordinates[index]
            XCTAssertEqual(stored.latitude, original.latitude, accuracy: 0.0001)
            XCTAssertEqual(stored.longitude, original.longitude, accuracy: 0.0001)
        }
    }
    
    func testClearAllLocations() async {
        guard let locationStorage else {
            XCTFail("LocationStorage should be initialized")
            return
        }
        
        let coordinates = [
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
        ]
        await locationStorage.updateAllLocations(coordinates)
        
        await locationStorage.clearAllLocations()
        let locations = await locationStorage.getAllLocations()
        
        XCTAssertTrue(locations.isEmpty, "Locations should be empty after clearing")
    }
    
    func testUpdateAndGetLastSaved() async throws {
        guard let locationStorage else {
            XCTFail("LocationStorage should be initialized")
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let date = Date()
        
        await locationStorage.updateLastSaved(location: coordinate, date: date)
        let lastSaved = await locationStorage.getLastSaved()
        
        let unwrappedLastSaved = try XCTUnwrap(lastSaved)
        XCTAssertEqual(unwrappedLastSaved.location.latitude, coordinate.latitude, accuracy: 0.0001)
        XCTAssertEqual(unwrappedLastSaved.location.longitude, coordinate.longitude, accuracy: 0.0001)
        XCTAssertEqual(unwrappedLastSaved.date, date)
    }
    
    func testMultipleLocationAppends() async {
        guard let locationStorage else {
            XCTFail("LocationStorage should be initialized")
            return
        }
        
        let coordinates = [
            CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
            CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        ]
        
        for coordinate in coordinates {
            await locationStorage.appendLocation(coordinate)
        }
        
        let locations = await locationStorage.getAllLocations()
        XCTAssertEqual(locations.count, coordinates.count)
        
        for (index, stored) in locations.enumerated() {
            let original = coordinates[index]
            XCTAssertEqual(stored.latitude, original.latitude, accuracy: 0.0001)
            XCTAssertEqual(stored.longitude, original.longitude, accuracy: 0.0001)
        }
    }
}
