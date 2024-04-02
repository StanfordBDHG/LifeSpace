//
//  Constants.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/2/24.
//

class Constants {
    
    static let prefConfirmedLogin = "PREF_CONFIRMED_LOGIN"
    static let prefFirstRunWasMarked = "PREF_FIRST_RUN"
    static let prefUserEmail = "PREF_USER_EMAIL"
    static let prefStudyID = "PREF_STUDY_ID"
    static let prefsNotificationsSchedule = "PREFS_NOTIFICATIONS_SCHEDULE"
    static let prefTrackingStatus = "PREF_TRACKING_STATUS"
    
    static let prefCareKitCoreDataInitDate = "PREF_CORE_DATA_INIT_DATE"
    static let prefHealthRecordsLastUploaded = "PREF_HEALTH_LAST_UPLOAD"
    
    static let notificationUserLogin = "NOTIFICATION_USER_LOGIN"
    
    static let dataBucketUserDetails = "userDetails"
    static let dataBucketSurveys = "ls_surveys"
    static let dataBucketHealthKit = "healthKit"
    static let dataBucketStorage = "storage"
    static let dataBucketMetrics = "metrics"
    
    static let onboardingDidComplete = "didCompleteOnboarding"
    
    static let JHFirstLocationRequest = "JHFirstLocationRequest"
    
    static let lastSurveyDate = "LAST_SURVEY_DATE"
    static let hourToOpenSurvey = 19 // Hour to open survey daily in military time

    static let minDistanceBetweenPoints = 100.0 // minimum distance between location points to record

    static let privacyPolicyURL = "https://michelleodden.com/cardinal-lifespace-privacy-policy/"
}
