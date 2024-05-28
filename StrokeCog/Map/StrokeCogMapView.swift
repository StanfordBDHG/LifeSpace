//
//  HomeView.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/2/24.
//  Copyright © 2024 StrokeCog. All rights reserved.
//

import MapboxMaps
import SpeziAccount
import SwiftUI

struct StrokeCogMapView: View {
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    @Environment(LocationModule.self) private var locationModule
    
    @State private var presentedContext: EventContext?
    @Binding private var presentingAccount: Bool
    
    @State private var showingSurveyAlert = false
    @State private var alertMessage = ""
    @State private var showingSurvey = false
    @State private var optionsPanelOpen = true
    
    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task {
                            await locationModule.fetchLocations()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
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
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}

struct StrokeCogMapView_Previews: PreviewProvider {
    static var previews: some View {
        StrokeCogMapView(presentingAccount: .constant(false))
            .previewWith(standard: StrokeCogStandard()) {
                StrokeCogScheduler()
                AccountConfiguration {
                    MockUserIdPasswordAccountService()
                }
            }
    }
}
