//
//  LocationUtils.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 7/12/22.
//  Copyright © 2022 LifeSpace. All rights reserved.
//

import CoreLocation
import Foundation

enum LocationUtils {
    /// Checks if the last two points are above the minimum distance apart required to record them for the study.
    /// - Parameters:
    ///   - previousLocation: the last point recorded
    ///   - currentLocation: the latest point
    /// - Returns: Boolean
    static func isAboveMinimumDistance(
        previousLocation: CLLocationCoordinate2D,
        currentLocation: CLLocationCoordinate2D
    ) -> Bool {
        let lastLocation = CLLocation(
            latitude: previousLocation.latitude,
            longitude: previousLocation.longitude
        )
        let newLocation = CLLocation(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude
        )
        let distanceInMeters = newLocation.distance(from: lastLocation)
        return distanceInMeters > Constants.minDistanceBetweenPoints
    }
}
