//
//  DailySurveyResponse.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/10/24.
//

import Foundation


struct DailySurveyResponse: Codable {
    var socialInteractionQuestion: Int?
    var leavingTheHouseQuestion: String?
    var emotionalWellBeingQuestion: Int?
    var physicalWellBeingQuestion: Int?
}
