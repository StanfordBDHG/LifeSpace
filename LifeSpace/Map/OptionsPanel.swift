//
//  OptionsPanel.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/4/24.
//

import ResearchKit
import ResearchKitSwiftUI
import Spezi
import SwiftUI


struct ButtonGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.content
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color("AccentColor")))
    }
}


struct OptionsPanel: View {
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    @Environment(LocationModule.self) private var locationModule
    @Environment(\.scenePhase) var scenePhase
    @Environment(LifeSpaceStandard.self) private var standard
    
    @State private var showingSurvey = false
    @State private var showingSurveyConfirmation = false
    @State private var shouldShowSurvey = false
    
    var body: some View {
        GroupBox {
            Button {
                self.showingSurvey.toggle()
            } label: {
                Text("OPTIONS_PANEL_SURVEY_BUTTON")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $showingSurvey) {
                DailySurveyTaskView(
                    showingSurvey: $showingSurvey
                )
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task {
                        _ = await standard.getLatestSurveyDate()
                        
                        if SurveyModule.shouldShowSurvey && !SurveyModule.surveyAlreadyTaken {
                            self.showingSurveyConfirmation = true
                        }
                    }
                }
            }
        }
        .groupBoxStyle(ButtonGroupBoxStyle())
        .sheet(isPresented: $showingSurveyConfirmation, onDismiss: {
            if shouldShowSurvey {
                self.showingSurvey.toggle()
                self.shouldShowSurvey.toggle()
            }
        }) {
            surveyConfirmationView
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    private var surveyConfirmationView: some View {
        VStack {
            Text("SURVEY_READY_QUESTION")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            Button(action: {
                self.showingSurveyConfirmation.toggle()
                self.shouldShowSurvey.toggle()
            }, label: {
                Text("YES")
                    .padding()
                    .frame(maxWidth: .infinity)
            })
            .padding()
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                self.showingSurveyConfirmation.toggle()
            }, label: {
                Text("NO")
                    .padding()
                    .frame(maxWidth: .infinity)
            })
            .padding()
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    OptionsPanel()
}
