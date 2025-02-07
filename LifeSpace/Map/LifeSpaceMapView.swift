//
//  HomeView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/2/24.
//  Copyright © 2024 LifeSpace. All rights reserved.
//

import MapboxMaps
import SpeziAccount
import SwiftUI


struct LifeSpaceMapView: View {
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    @Environment(LocationModule.self) private var locationModule
    
    @State private var presentedContext: EventContext?
    @Binding private var presentingAccount: Bool
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSurvey = false
    @State private var optionsPanelOpen = true
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapManagerViewWrapper()
                
                if !trackingOn {
                    locationTrackingOverlay
                }
                
                VStack {
                    Spacer()
                    GroupBox {
                        optionsPanelButton
                        if optionsPanelOpen {
                            OptionsPanel()
                        }
                    }
                }
                if isRefreshing {
                    RefreshIcon()
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
                        refreshMap()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .accessibilityLabel("REFRESHING_MAP")
                    }
                    .disabled(isRefreshing)
                }
            }
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            refreshMap()
        }
    }
    
    private var locationTrackingOverlay: some View {
        VStack {
            Spacer()
            GroupBox {
                Text("LOCATION_NOT_TRACKED")
                    .padding()
                Button(action: {
                    self.trackingOn = true
                    self.locationModule.startTracking()
                }) {
                    Text("TURN_TRACKING_ON")
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
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
    
    private func refreshMap() {
        guard !isRefreshing else {
            return
        }
        
        Task {
            isRefreshing = true
            do {
                try await locationModule.fetchLocations()
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isRefreshing = false
        }
    }
}
