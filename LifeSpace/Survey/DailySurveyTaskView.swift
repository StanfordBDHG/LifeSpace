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
        if !showingSurvey {
            EmptyView()
        } else if SurveyModule.surveyAlreadyTaken {
            surveyTakenView
        } else if SurveyModule.isPreviousDaySurvey && !acknowledgedPreviousDaySurvey {
            previousDaySurveyView
        } else if SurveyModule.shouldShowSurvey {
            Group {
                ORKOrderedTaskView(tasks: DailySurveyTask(identifier: "DailySurveyTask")) { result in
                    guard case let .completed(taskResult) = result else {
                        showingSurvey = false
                        return
                    }
                    
                    Task { @MainActor in
                        await saveResponse(taskResult: taskResult)
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
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .accessibilityLabel("SURVEY_TAKEN_NOTICE")

            Text("SURVEY_TAKEN_NOTICE")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)

            Button(action: {
                self.showingSurvey = false
            }, label: {
                Text("OK")
                    .padding()
            })
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }
    
    private var previousDaySurveyView: some View {
        VStack {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .accessibilityLabel("PREVIOUS_DAY_SURVEY_LABEL")

            Text("PREVIOUS_DAY_SURVEY_NOTICE")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)

            Button(action: {
                self.acknowledgedPreviousDaySurvey = true
            }, label: {
                Text("CONTINUE")
                    .padding()
            })
            .buttonStyle(.borderedProminent)

            Spacer()
        }
    }
    
    private var surveyUnavailableView: some View {
        VStack {
            Spacer()
            
            Image(systemName: "clock.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .accessibilityLabel("SURVEY_NOT_AVAILABLE_MESSAGE")
            
            Text("SURVEY_NOT_AVAILABLE_MESSAGE")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)

            Spacer()

            Button(action: {
                self.showingSurvey.toggle()
            }, label: {
                Text("CLOSE")
                    .padding()
            })
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
    
    @MainActor
    private func saveResponse(taskResult: ORKTaskResult) async {
        do {
            savingSurvey = true
            let response = try SurveyModule.createResponse(from: taskResult)
            try await standard.add(response: response)
            
            // Update the last survey date in UserDefaults
            UserDefaults.standard.set(response.surveyDate, forKey: StorageKeys.lastSurveyDate)
            savingSurvey = false
        } catch {
            savingSurvey = false
            self.errorMessage = error.localizedDescription
            self.didError.toggle()
        }
    }
}

#Preview {
    DailySurveyTaskView(showingSurvey: .constant(true))
}
