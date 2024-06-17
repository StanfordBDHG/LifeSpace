//
//  DailySurveyResponse.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/10/24.
//

import Foundation


struct DailySurveyResponse: Codable {
    var surveyName: String?
    var surveyDate: String?
    var studyID: String?
    var updatedBy: String?
    var timestamp: Date?
    var socialInteractionQuestion: Int?
    var leavingTheHouseQuestion: Int?
    var emotionalWellBeingQuestion: Int?
    var physicalWellBeingQuestion: Int?
}
