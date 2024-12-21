//
// This source file is part of LifeSpace based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

/// Constants shared across the Spezi Teamplate Application to access storage information including the `AppStorage` and `SceneStorage`
enum StorageKeys {
    /// A `Bool` flag indicating of the onboarding was completed.
    static let onboardingFlowComplete = "onboardingFlow.complete"
    /// A `Step` flag indicating the current step in the onboarding process.
    static let onboardingFlowStep = "onboardingFlow.step"
    /// A `String` containing the user's study ID.
    static let studyID = "studyID"
    /// A `String` containing the currently selected home tab.
    static let homeTabSelection = "home.tabselection"
    /// A `Bool` representing whether the user has chosen to enable or disable location tracking.
    static let trackingPreference = "tracking.preference"
    /// A `String` containing the date of the last survey the user has taken.
    static let lastSurveyDate = "lastSurveyDate"
    /// A `Bool` representing whether location permissions have been previously requested.
    static let isFirstLocationRequest = "isFirstLocationRequest"
    /// `Date`s containing the timestamp of the last successful transmission for surveys.
    static let lastSurveyTransmissionDate = "lastSurveyTransmissionDate"
    /// `Date`s containing the timestamp of the last successful transmission for location data.
    static let lastLocationTransmissionDate = "lastLocationTransmissionDate"
}
