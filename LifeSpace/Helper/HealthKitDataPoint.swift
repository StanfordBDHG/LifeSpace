//
//  HealthKitDataPoint.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 7/9/24.
//

import Foundation
import ModelsR4


struct HealthKitDataPoint: Codable {
    var studyID: String
    var UpdatedBy: String // swiftlint:disable:this identifier_name
    var resource: ResourceProxy
}
