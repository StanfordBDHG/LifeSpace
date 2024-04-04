//
//  LocationDataPoint.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/4/24.
//

import CoreLocation
import Foundation

struct LocationDataPoint: Codable {
    var currentDate: Date
    var time: TimeInterval
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var studyID: String = ""
    var updatedBy: String = ""
}
