//
//  SurveyModule.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 7/12/24.
//

import Foundation


enum SurveyModule {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    static var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }
    
    static var isPreviousDaySurvey: Bool {
        /// If the user is taking the survey before 7am, they should be informed that they are taking the
        /// previous day's survey
        currentHour < 7
    }
    
    static var surveyAlreadyTaken: Bool {
        let lastSurveyDateString = UserDefaults.standard.string(forKey: StorageKeys.lastSurveyDate)
        
        /// Determine the survey date based on the current time
        let surveyDate: Date
        if currentHour < 7 {
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
        /// The survey should only be shown if it between 7pm and 7am
        currentHour < 7 || currentHour >= 19
    }
}
