//
//  DailySurveyResponse.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/10/24.
//

import Foundation


struct DailySurveyResponse: Codable {
    var socialInteractionQuestion: Int?
    var leavingTheHouseQuestion: Int?
    var emotionalWellBeingQuestion: Int?
    var physicalWellBeingQuestion: Int?
}
