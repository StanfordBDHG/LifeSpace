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
    
    @State private var showingSurveyAlert = false
    @State private var showingSurvey = false
    @State private var showingStartSurveyModal = false
    
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
                DailySurveyTaskView(showingSurvey: $showingSurvey)
            }
            .sheet(isPresented: $showingStartSurveyModal) {
                startSurveyModal
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task {
                        _ = await standard.getLatestSurveyDate()
                        launchSurvey()
                    }
                }
            }
        }.groupBoxStyle(ButtonGroupBoxStyle())
    }
    
    private var startSurveyModal: some View {
        VStack {
            Text("SURVEY_READY_QUESTION")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            Button(action: {
                self.showingSurvey = true
                self.showingStartSurveyModal = false
            }, label: {
                Text("YES")
                    .padding()
                    .frame(maxWidth: .infinity)
            })
            .padding()
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                self.showingStartSurveyModal = false
            }, label: {
                Text("NO")
                    .padding()
                    .frame(maxWidth: .infinity)
            })
            .padding()
            .buttonStyle(.bordered)
        }
    }
    
    private func launchSurvey() {
        if SurveyModule.shouldShowSurvey && !SurveyModule.surveyAlreadyTaken {
            self.showingStartSurveyModal = true
        }
    }
}

#Preview {
    OptionsPanel()
}
