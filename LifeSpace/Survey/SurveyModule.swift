//
//  SurveyModule.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 7/12/24.
//

import Foundation
import ResearchKit


enum SurveyModule {
    enum SurveyModuleError: Error {
        case invalidStudyID
    }
    
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    static var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }
    
    static var isPreviousDaySurvey: Bool {
        /// If the user is taking the survey in the morning, they should be informed that their
        /// results will apply to the previous day not the current day.
        currentHour < Constants.hourToCloseSurvey
    }
    
    static var surveyAlreadyTaken: Bool {
        let lastSurveyDateString = UserDefaults.standard.string(forKey: StorageKeys.lastSurveyDate)
        
        /// Determine the survey date based on the current time
        let surveyDate: Date
        if currentHour < Constants.hourToCloseSurvey {
            surveyDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())?.startOfDay ?? Date().startOfDay
        } else {
            surveyDate = Date().startOfDay
        }
        
        /// Format the survey date to a string
        let surveyDateString = dateFormatter.string(from: surveyDate)
        
        /// Compare the last survey date with the calculated survey date
        return lastSurveyDateString == surveyDateString
    }

    static var shouldShowSurvey: Bool {
        currentHour < Constants.hourToCloseSurvey || currentHour >= Constants.hourToOpenSurvey
    }
    
    static func createResponse(from taskResult: ORKTaskResult) throws -> DailySurveyResponse {
        guard let studyID = UserDefaults.standard.string(forKey: StorageKeys.studyID) else {
            throw SurveyModuleError.invalidStudyID
        }
        
        /// If the user is taking the survey the morning after, the `surveyDate` should reflect the previous day,
        /// otherwise it should reflect the current day.
        let surveyDate: Date
        if currentHour < Constants.hourToCloseSurvey {
            surveyDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())?.startOfDay ?? Date().startOfDay
        } else {
            surveyDate = Date().startOfDay
        }
        let surveyDateString = dateFormatter.string(from: surveyDate)
        
        // swiftlint:disable legacy_objc_type
        var socialInteractionAnswer = -1
        if let socialInteractionQuestion = taskResult.stepResult(forStepIdentifier: "SocialInteractionQuestion"),
           let result = socialInteractionQuestion.firstResult as? ORKChoiceQuestionResult,
           let answer = result.choiceAnswers?.first as? NSNumber {
            socialInteractionAnswer = answer.intValue
        }
        
        var leavingTheHouseAnswer = -1
        if let leavingTheHouseQuestion = taskResult.stepResult(forStepIdentifier: "LeavingTheHouseQuestion"),
           let result = leavingTheHouseQuestion.firstResult as? ORKChoiceQuestionResult,
           let answer = result.choiceAnswers?.first as? NSNumber {
            leavingTheHouseAnswer = answer.intValue
        }
        
        var emotionalWellBeingAnswer = -1
        if let emotionalWellBeingQuestion = taskResult.stepResult(forStepIdentifier: "EmotionalWellBeingQuestion")?.results,
           let answer = emotionalWellBeingQuestion[0] as? ORKBooleanQuestionResult {
            let result = answer.booleanAnswer
            if let value = result?.intValue {
                emotionalWellBeingAnswer = value
            }
        }
        
        var physicalWellBeingAnswer = -1
        if let physicalWellBeingQuestion = taskResult.stepResult(forStepIdentifier: "PhysicalWellBeingQuestion"),
           let result = physicalWellBeingQuestion.firstResult as? ORKChoiceQuestionResult,
           let answer = result.choiceAnswers?.first as? NSNumber {
            physicalWellBeingAnswer = answer.intValue
        }
        
        return DailySurveyResponse(
            surveyName: "dailySurveyTask",
            surveyDate: surveyDateString,
            studyID: studyID,
            UpdatedBy: "", // To be set by `LifeSpaceStandard` add(response:) method
            timestamp: Date(),
            socialInteractionQuestion: socialInteractionAnswer,
            leavingTheHouseQuestion: leavingTheHouseAnswer,
            emotionalWellBeingQuestion: emotionalWellBeingAnswer,
            physicalWellBeingQuestion: physicalWellBeingAnswer
        )
    }
}
