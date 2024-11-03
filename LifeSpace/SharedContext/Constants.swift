//
//  Constants.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/2/24.
//

/// Constants shared across the application for settings
enum Constants {
    /// Hour to open the survey daily (in 24 hour time)
    static let hourToOpenSurvey = 19
    /// Minimum distance between locations to record (in meters)
    static let minDistanceBetweenPoints = 100.0
    /// URL of the privacy policy for the app
    static let privacyPolicyURL = "https://michelleodden.com/cardinal-lifespace-privacy-policy/"
    /// User collection on Firestore
    static let userCollectionName = "ls_users"
    /// Location data collection on Firestore
    static let locationDataCollectionName = "ls_location_data"
    /// HealthKit data collection on Firestore
    static let healthKitCollectionName = "ls_healthkit"
    /// Survey collection on Firestore
    static let surveyCollectionName = "ls_surveys"
    /// Consent bucket name
    static let consentBucketName = "ls_consent"
    /// Default bundle identifier
    static let defaultBundleIdentifier = "edu.stanford.lifespace"
}
