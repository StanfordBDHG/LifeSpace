//
//  HomeView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 5/18/22.
//  Copyright © 2022 LifeSpace. All rights reserved.
//

import SwiftUI
@_spi(Experimental) import MapboxMaps

// swiftlint:disable closure_body_length file_types_order
struct MapView: View {
    @State private var showingSurveyAlert = false
    @State private var alertMessage = ""
    @State private var showingSurvey = false
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    @State private var optionsPanelOpen = true
    
    init() {
        MapboxOptions.accessToken = ""
    }

    var body: some View {
        ZStack {
            Map()
                .ignoresSafeArea()

            // overlay buttons on map
            VStack {
                Spacer()

                GroupBox {

                    Button {
                        withAnimation {
                            self.optionsPanelOpen.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Options")
                            Spacer()
                            Image(systemName: self.optionsPanelOpen ? "chevron.down" : "chevron.up")
                        }
                    }

                    if self.optionsPanelOpen {
                        GroupBox {
                            Button {
                                // First check if it's too early to take the survey,
                                // and if not, then check to make sure it hasn't been
                                // taken already today.
//                                if !SurveyRules.isAfterStartHour() {
//                                    self.alertMessage = SurveyRules.tooEarlyMessage
//                                    self.showingSurveyAlert.toggle()
//                                } else if !SurveyRules.wasNotTakenToday() {
//                                    self.alertMessage = SurveyRules.alreadyTookSurveyMessage
//                                    self.showingSurveyAlert.toggle()
//                                } else {
//                                    self.showingSurvey.toggle()
//                                }
                            } label: {
                                Text("Take Daily Survey")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                            .alert(isPresented: $showingSurveyAlert) {
                                Alert(title: Text("Survey Not Available"),
                                      message: Text(self.alertMessage),
                                      dismissButton: .default(Text("OK")))
                            }
                            .sheet(isPresented: $showingSurvey) {
//                                CKTaskViewController(tasks: DailySurveyTask(showInstructions: false))
//                                    .ignoresSafeArea(.container, edges: .bottom)
//                                    .ignoresSafeArea(.keyboard, edges: .bottom)
                            }
                        }.groupBoxStyle(ButtonGroupBoxStyle())

                        GroupBox {
                            Toggle("Track My Location", isOn: $trackingOn)
                                .onChange(of: trackingOn) { _ in
                                    if trackingOn {
                                        // LocationService.shared.startTracking()
                                    } else {
                                        // LocationService.shared.stopTracking()
                                    }
                                }
                        }
                    }
                }
            }.onAppear {
                // Make sure last survey date is updated
                async {
                    do {
                        // try await CKStudyUser.shared.getLastSurveyDate()
                    } catch {
                        print("Error updating last survey date.")
                    }
                }
            }
        }
    }
}

struct ButtonGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color("primaryRed")))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

