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
    
    
    var body: some View {
        ORKOrderedTaskView(tasks: DailySurveyTask(identifier: "DailySurveyTask")) { result in
            guard case let .completed(taskResult) = result else {
                showingSurvey.toggle()
                return
            }
            
            var response = DailySurveyResponse()
            
            if let socialInteractionQuestion = taskResult.stepResult(forStepIdentifier: "SocialInteractionQuestion")?.results {
                let answer = socialInteractionQuestion[0] as? ORKScaleQuestionResult
                let result = answer?.scaleAnswer
                response.socialInteractionQuestion = result?.intValue ?? -1
            }
            
            if let leavingTheHouseQuestion = taskResult.stepResult(forStepIdentifier: "LeavingTheHouseQuestion")?.results {
                let answer = leavingTheHouseQuestion[0] as? ORKTextQuestionResult
                let result = answer?.textAnswer
                response.leavingTheHouseQuestion = result ?? "-1"
            }
            
            if let emotionalWellBeingQuestion = taskResult.stepResult(forStepIdentifier: "EmotionalWellBeingQuestion")?.results {
                let answer = emotionalWellBeingQuestion[0] as? ORKBooleanQuestionResult
                let result = answer?.booleanAnswer
                response.emotionalWellBeingQuestion = result?.boolValue
            }
            
            if let physicalWellBeingQuestion = taskResult.stepResult(forStepIdentifier: "PhysicalWellBeingQuestion")?.results {
                let answer = physicalWellBeingQuestion[0] as? ORKScaleQuestionResult
                let result = answer?.scaleAnswer
                response.physicalWellBeingQuestion = result?.intValue ?? -1
            }
            
            do {
                try await standard.add(response: response)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            
            showingSurvey.toggle()
        }
    }
}

#Preview {
    DailySurveyTaskView(showingSurvey: .constant(true))
}
