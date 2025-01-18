//
//  CompletedSurveysView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 1/4/25.
//


import Spezi
import SpeziFirestore
import SwiftUI

struct CompletedSurveysView: View {
    @Environment(LifeSpaceStandard.self) private var standard
    
    @State private var surveys: [DailySurveyResponse] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading surveys...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
            } else if surveys.isEmpty {
                ContentUnavailableView(
                    "No Surveys",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("You haven't completed any surveys yet.")
                )
            } else {
                surveyList
            }
        }
        .navigationTitle("Completed Surveys")
        .task {
            await fetchSurveys()
        }
    }
    
    private var surveyList: some View {
        List(surveys.sorted { $0.timestamp > $1.timestamp }, id: \.timestamp) { survey in
            VStack(alignment: .leading, spacing: 8) {
                Text(survey.surveyDate)
                    .font(.headline)
                
                Text("Submitted: \(survey.timestamp.formatted(date: .long, time: .shortened))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Grid(alignment: .leading) {
                    GridRow {
                        Text("Social Interactions:")
                        Text(formatSocialInteraction(survey.socialInteractionQuestion))
                    }
                    GridRow {
                        Text("Time Outside:")
                        Text(formatTimeOutside(survey.leavingTheHouseQuestion))
                    }
                    GridRow {
                        Text("Was Happy:")
                        Text(survey.emotionalWellBeingQuestion == 1 ? "Yes" : "No")
                    }
                    GridRow {
                        Text("Fatigue Level:")
                        let fatigue = survey.emotionalWellBeingQuestion
                        if fatigue >= 0 {
                            Text("\(fatigue)/4")
                        } else {
                            Text("Not answered")
                        }
                    }
                }
                .font(.subheadline)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func fetchSurveys() async {
        do {
            try await surveys = standard.fetchSurveys()
            isLoading = false
        } catch {
            errorMessage = "Could not load surveys: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func formatSocialInteraction(_ value: Int) -> String {
        switch value {
        case 0: return "0"
        case 1: return "1-4"
        case 2: return "5-10"
        case 3: return "10+"
        default: return "Not answered"
        }
    }
    
    private func formatTimeOutside(_ value: Int) -> String {
        switch value {
        case 0: return "None"
        case 1: return "< 1 hour"
        case 2: return "1-4 hours"
        case 3: return "4+ hours"
        default: return "Not answered"
        }
    }
}

#Preview {
    NavigationStack {
        CompletedSurveysView()
    }
}
