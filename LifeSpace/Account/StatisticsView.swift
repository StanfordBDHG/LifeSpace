//
//  StatisticsView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 1/4/25.
//


import SwiftUI

struct StatisticsView: View {
    @AppStorage(StorageKeys.lastSurveyTransmissionDate) private var lastSurveyTransmissionDate = "None"
    @AppStorage(StorageKeys.lastLocationTransmissionDate) private var lastLocationTransmissionDate = "None"
    @AppStorage(StorageKeys.lastHealthKitTransmissionDate) private var lastHealthKitTransmissionDate = "None"
    
    var body: some View {
        Form {
            Section(header: Text("LAST_SURVEY_TRANSMISSION_SECTION")) {
                Text(lastSurveyTransmissionDate)
            }
            Section(header: Text("LAST_LOCATION_TRANSMISSION_SECTION")) {
                Text(lastLocationTransmissionDate)
            }
            Section(header: Text("LAST_HEALTHKIT_TRANSMISSION_SECTION")) {
                Text(lastHealthKitTransmissionDate)
            }
        }
        .navigationTitle("STATISTICS_TITLE")
    }
}
