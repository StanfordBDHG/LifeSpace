//
//  HomeView.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/2/24.
//  Copyright © 2024 StrokeCog. All rights reserved.
//

import MapboxMaps
import SwiftUI

struct StrokeCogMapView: View {
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    
    @State private var showingSurveyAlert = false
    @State private var alertMessage = ""
    @State private var showingSurvey = false
    @State private var optionsPanelOpen = true
    
    var body: some View {
        ZStack {
            MapManagerViewWrapper()
            VStack {
                Spacer()
                GroupBox {
                    optionsPanelButton
                    if self.optionsPanelOpen {
                        OptionsPanel()
                    }
                }
            }
        }
    }
    
    private var optionsPanelButton: some View {
        Button {
            withAnimation {
                self.optionsPanelOpen.toggle()
            }
        } label: {
            HStack {
                Text("OPTIONS_PANEL_TITLE")
                Spacer()
                Image(systemName: self.optionsPanelOpen ? "chevron.down" : "chevron.up")
                    .accessibilityLabel(Text(verbatim: "Toggle Panel"))
            }
        }
    }
}

struct StrokeCogMapView_Previews: PreviewProvider {
    static var previews: some View {
        StrokeCogMapView()
    }
}
