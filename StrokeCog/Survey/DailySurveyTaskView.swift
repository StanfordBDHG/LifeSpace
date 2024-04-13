//
//  DailySurveyTaskView.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/10/24.
//

import ResearchKit
import ResearchKitSwiftUI
import SwiftUI


struct DailySurveyTaskView: View {
    @Environment(StrokeCogStandard.self) private var standard
    @Binding var showingSurvey: Bool
    @State private var didError = false
    @State private var errorMessage = ""
    
    
    var body: some View {
        if shouldShowSurvey {
            Group {
                ORKOrderedTaskView(tasks: DailySurveyTask(identifier: "DailySurveyTask")) { result in
                    guard case let .completed(taskResult) = result else {
                        showingSurvey.toggle()
                        return
                    }
                    
                    Task {
                        await saveResponse(taskResult: taskResult)
                        showingSurvey.toggle()
                    }
                }
            }
            .alert(errorMessage, isPresented: $didError) { }
        } else {
            surveyUnavailableView
        }
    }
    
    private var surveyUnavailableView: some View {
        VStack {
            Text("SURVEY_NOT_AVAILABLE_MESSAGE")
                .padding()
                .multilineTextAlignment(.center)
            
            Button {
                self.showingSurvey.toggle()
            } label: {
                Text("CLOSE")
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var shouldShowSurvey: Bool {
        // TODO: Add check if survey has already been answered today
        
        /// The survey should only be shown if it between 7pm and 7am
        let currentHour = Calendar.current.component(.hour, from: Date())
        return currentHour < 7 || currentHour >= 19
    }
    
    private func saveResponse(taskResult: ORKTaskResult) async {
        var response = DailySurveyResponse()
        
        if let socialInteractionQuestion = taskResult.stepResult(forStepIdentifier: "SocialInteractionQuestion")?.results {
            let answer = socialInteractionQuestion[0] as? ORKScaleQuestionResult
            if let result = answer?.scaleAnswer {
                response.socialInteractionQuestion = Int(truncating: result)
            } else {
                response.socialInteractionQuestion = -1
            }
        }
        
        if let leavingTheHouseQuestion = taskResult.stepResult(forStepIdentifier: "LeavingTheHouseQuestion")?.results {
            let answer = leavingTheHouseQuestion[0] as? ORKNumericQuestionResult
            if let result = answer?.numericAnswer {
                response.leavingTheHouseQuestion = Int(truncating: result)
            } else {
                response.leavingTheHouseQuestion = -1
            }
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
        } catch {
            self.errorMessage = error.localizedDescription
            self.didError.toggle()
        }
    }
}

struct SaveDetails: Identifiable {
    let name: String
    let error: String
    let id = UUID()
}

#Preview {
    DailySurveyTaskView(showingSurvey: .constant(true))
}
