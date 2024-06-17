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

struct OptionsPanel: View {
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    @Environment(LocationModule.self) private var locationModule
    @Environment(\.scenePhase) var scenePhase
    @Environment(LifeSpaceStandard.self) private var standard
    
    @State private var showingSurveyAlert = false
    @State private var showingSurvey = false
    
    var body: some View {
        GroupBox {
            Button {
                self.showingSurvey.toggle()
            } label: {
                Text("OPTIONS_PANEL_SURVEY_BUTTON")
                    .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $showingSurvey) {
                DailySurveyTaskView(showingSurvey: $showingSurvey)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    Task {
                        await standard.getLatestSurveyDate()
                    }
                }
            }
        }
        
        GroupBox {
            Toggle("TRACK_LOCATION_BUTTON", isOn: $trackingOn)
                .onChange(of: trackingOn) {
                    if trackingOn {
                        locationModule.startTracking()
                    } else {
                        locationModule.stopTracking()
                    }
                }
        }
    }
}

#Preview {
    OptionsPanel()
}
