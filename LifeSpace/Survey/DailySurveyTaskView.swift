//
//  DailySurveyTaskView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/10/24.
//

import ResearchKit
import ResearchKitSwiftUI
import SwiftUI


struct DailySurveyTaskView: View {
    @Environment(LifeSpaceStandard.self) private var standard
    @Binding var showingSurvey: Bool
    @State private var didError = false
    @State private var errorMessage = ""
    @State private var acknowledgedPreviousDaySurvey = false
    @State private var savingSurvey = false
    
    
    var body: some View {
        if surveyAlreadyTaken {
            surveyTakenView
        } else if isPreviousDaySurvey && !acknowledgedPreviousDaySurvey {
            previousDaySurveyView
        } else if shouldShowSurvey {
            Group {
                ORKOrderedTaskView(tasks: DailySurveyTask(identifier: "DailySurveyTask")) { result in
                    guard case let .completed(taskResult) = result else {
                        showingSurvey = false
                        return
                    }
                    
                    Task {
                        savingSurvey = true
                        await saveResponse(taskResult: taskResult)
                        savingSurvey = false
                        showingSurvey = false
                    }
                }
                .overlay {
                    if savingSurvey {
                        savingSurveyView
                    }
                }
            }
            .alert(errorMessage, isPresented: $didError) { }
        } else {
            surveyUnavailableView
        }
    }
    
    private var savingSurveyView: some View {
        VStack {
            Text("SAVING_SURVEY")
            ProgressView()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(.rect(cornerRadius: 10))
    }

    private var surveyTakenView: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .accessibilityLabel("SURVEY_TAKEN_NOTICE")
            
            Text("SURVEY_TAKEN_NOTICE")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)
            
            Button("OK") {
                self.showingSurvey = false
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
    }
    
    private var previousDaySurveyView: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .accessibilityLabel("PREVIOUS_DAY_SURVEY_LABEL")
            
            Text("PREVIOUS_DAY_SURVEY_NOTICE")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)
            
            Button("CONTINUE") {
                self.acknowledgedPreviousDaySurvey = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
    }
    
    private var surveyUnavailableView: some View {
        VStack {
            Image(systemName: "clock.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .accessibilityLabel("SURVEY_NOT_AVAILABLE_MESSAGE")
            
            Text("SURVEY_NOT_AVAILABLE_MESSAGE")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)
            
            Button("CLOSE") {
                self.showingSurvey.toggle()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    private var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }
    
    private var isPreviousDaySurvey: Bool {
        /// If the user is taking the survey before 7am, they should be informed that they are taking the
        /// previous day's survey
        currentHour < 7
    }
    
    private var surveyAlreadyTaken: Bool {
        let lastSurveyDateString = UserDefaults.standard.string(forKey: StorageKeys.lastSurveyDate)
        
        // Determine the survey date based on the current time
        let surveyDate: Date
        if currentHour < 7 {
            surveyDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())?.startOfDay ?? Date().startOfDay
        } else {
            surveyDate = Date().startOfDay
        }
        
        // Format the survey date to a string
        let surveyDateString = dateFormatter.string(from: surveyDate)
        
        // Compare the last survey date with the calculated survey date
        return lastSurveyDateString == surveyDateString
    }

    
    private var shouldShowSurvey: Bool {
        /// The survey should only be shown if it between 7pm and 7am
        currentHour < 7 || currentHour >= 19
    }
    
    private func saveResponse(taskResult: ORKTaskResult) async {
        var response = DailySurveyResponse()
        
        response.surveyName = "dailySurveyTask"
        
        /// If the user is taking the survey before 7am, the `surveyDate` should reflect the previous day,
        /// otherwise it should reflect the current day.
        let surveyDate: Date
        if currentHour < 7 {
            surveyDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())?.startOfDay ?? Date().startOfDay
        } else {
            surveyDate = Date().startOfDay
        }
        let surveyDateString = dateFormatter.string(from: surveyDate)
        response.surveyDate = surveyDateString
        
        // swiftlint:disable legacy_objc_type
        if let socialInteractionQuestion = taskResult.stepResult(forStepIdentifier: "SocialInteractionQuestion"),
           let result = socialInteractionQuestion.firstResult as? ORKChoiceQuestionResult,
           let answer = result.choiceAnswers?.first as? NSNumber {
            response.socialInteractionQuestion = answer.intValue
        } else {
            response.socialInteractionQuestion = -1
        }
        
        if let leavingTheHouseQuestion = taskResult.stepResult(forStepIdentifier: "LeavingTheHouseQuestion"),
           let result = leavingTheHouseQuestion.firstResult as? ORKChoiceQuestionResult,
           let answer = result.choiceAnswers?.first as? NSNumber {
            response.leavingTheHouseQuestion = answer.intValue
        } else {
            response.leavingTheHouseQuestion = -1
        }
        
        if let emotionalWellBeingQuestion = taskResult.stepResult(forStepIdentifier: "EmotionalWellBeingQuestion")?.results {
            let answer = emotionalWellBeingQuestion[0] as? ORKBooleanQuestionResult
            let result = answer?.booleanAnswer
            response.emotionalWellBeingQuestion = result?.intValue
        }
        
        if let physicalWellBeingQuestion = taskResult.stepResult(forStepIdentifier: "PhysicalWellBeingQuestion")?.results {
            let answer = physicalWellBeingQuestion[0] as? ORKScaleQuestionResult
            if let result = answer?.scaleAnswer {
                response.physicalWellBeingQuestion = Int(truncating: result)
            } else {
                response.physicalWellBeingQuestion = -1
            }
        }
        
        do {
            try await standard.add(response: response)
            
            // Update the last survey date in UserDefaults
            UserDefaults.standard.set(surveyDateString, forKey: StorageKeys.lastSurveyDate)
        } catch {
            self.errorMessage = error.localizedDescription
            self.didError.toggle()
        }
    }
}

#Preview {
    DailySurveyTaskView(showingSurvey: .constant(true))
}
