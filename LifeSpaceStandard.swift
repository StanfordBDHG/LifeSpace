//
// This source file is part of the LifeSpace based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import HealthKitOnFHIR
import OSLog
import PDFKit
import Spezi
@_spi(TestingSupport) import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirebaseAccountStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI


actor LifeSpaceStandard: Standard,
                         EnvironmentAccessible,
                         HealthKitConstraint,
                         OnboardingConstraint,
                         AccountNotifyConstraint {
    enum LifeSpaceStandardError: Error {
        case userNotAuthenticatedYet
        case invalidStudyID
    }
    
    var studyID: String {
        UserDefaults.standard.string(forKey: StorageKeys.studyID) ?? "unknownStudyID"
    }
    
    @Dependency(FirestoreAccountStorage.self) var accountStorage: FirestoreAccountStorage?
    
    @Application(\.logger) private var logger
    
    @Dependency(FirebaseConfiguration.self) private var configuration
    
    init() {}
    
    func respondToEvent(_ event: AccountNotifications.Event) async {
        if case let .deletingAccount(accountId) = event {
            do {
                try await configuration.userDocumentReference(for: accountId).delete()
            } catch {
                logger.error("Could not delete user document: \(error)")
            }
        }
    }
    
    
    /// Saves a HealthKit sample to Firestore
    /// - Parameter sample: an `HKSample` from HealthKit
    func add(sample: HKSample) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            logger.error("User is not logged in.")
            return
        }
        
        do {
            let resource = try sample.resource
            let encoder = FirebaseFirestore.Firestore.Encoder()
            var dataDict = try encoder.encode(resource)
            
            /// The `UpdatedBy` field is checked by the mHealth platform security rules
            dataDict["UpdatedBy"] = userId
            dataDict["studyID"] = studyID
            
            try await healthKitDocument(id: sample.id).setData(dataDict)
            
            // Store the timestamp of this transmission for debugging purposes
            storeCurrentTimestamp(forKey: StorageKeys.lastHealthKitTransmissionDate)
        } catch {
            logger.error("Could not store HealthKit sample: \(error) Sample: \(sample.sampleType)")
        }
    }
    
    func remove(sample: HKDeletedObject) async {
        do {
            try await healthKitDocument(id: sample.uuid).delete()
        } catch {
            logger.error("Could not remove HealthKit sample: \(error)")
        }
    }
    
    
    /// Saves a FHIR QuestionnaireResponse to Firestore
    /// - Parameter response: A FHIR R4 `QuestionnaireResponse`
    func add(response: ModelsR4.QuestionnaireResponse) async {
        let id = response.identifier?.value?.value?.string ?? UUID().uuidString
        
        do {
            try await configuration.userDocumentReference
                .collection(Constants.surveyCollectionName)
                .document(id)
                .setData(from: response)
        } catch {
            logger.error("Could not store questionnaire response: \(error)")
        }
    }
    
    
    /// Saves a location data point to Firestore, appending a timestamp, study ID, and user ID.
    /// - Parameter location: A `CLLocationCoordinate2D` containing the latitude and longitude of a location.
    func add(location: CLLocationCoordinate2D) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw LifeSpaceStandardError.userNotAuthenticatedYet
        }
        
        guard let studyID = UserDefaults.standard.string(forKey: StorageKeys.studyID) else {
            throw LifeSpaceStandardError.invalidStudyID
        }
        
        // Check that we only save points if location tracking is turned on
        guard UserDefaults.standard.bool(forKey: StorageKeys.trackingPreference) else {
            return
        }
        
        let dataPoint = LocationDataPoint(
            currentDate: Date(),
            time: Date().timeIntervalSince1970,
            latitude: location.latitude,
            longitude: location.longitude,
            studyID: studyID,
            UpdatedBy: userId
        )
        
        try await configuration.userDocumentReference
            .collection(Constants.locationDataCollectionName)
            .document(UUID().uuidString)
            .setData(from: dataPoint)
        
        // Store a timestamp of this transmission for debugging purposes
        storeCurrentTimestamp(forKey: StorageKeys.lastLocationTransmissionDate)
    }
    
    func fetchLocations(on date: Date = Date()) async throws -> [CLLocationCoordinate2D] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = Date(timeInterval: 24 * 60 * 60, since: startOfDay)
        
        var locations = [CLLocationCoordinate2D]()
        
        do {
            let snapshot = try await configuration.userDocumentReference
                .collection(Constants.locationDataCollectionName)
                .whereField("currentDate", isGreaterThanOrEqualTo: startOfDay)
                .whereField("currentDate", isLessThan: endOfDay)
                .getDocuments()
            
            for document in snapshot.documents {
                if let longitude = document.data()["longitude"] as? CLLocationDegrees,
                   let latitude = document.data()["latitude"] as? CLLocationDegrees {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: latitude,
                        longitude: longitude
                    )
                    locations.append(coordinate)
                }
            }
        } catch {
            self.logger.error("Error fetching location data: \(String(describing: error))")
            throw error
        }
        
        return locations
    }

    /// Saves a LifeSpace daily survey response to Firestore
    /// - Parameter response: A `DailySurveyResponse`
    func add(response: DailySurveyResponse) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw LifeSpaceStandardError.userNotAuthenticatedYet
        }
        
        var response = response
        
        response.timestamp = Date()
        response.studyID = studyID
        response.UpdatedBy = userId
        
        try await configuration.userDocumentReference
            .collection(Constants.surveyCollectionName)
            .document(UUID().uuidString)
            .setData(from: response)
        
        // Update the user document with the latest survey date
        try await configuration.userDocumentReference.setData(
            [
                "latestSurveyDate": response.surveyDate ?? ""
            ],
            merge: true
        )
        
        // Store a timestamp of this transmission for debugging purposes
        storeCurrentTimestamp(forKey: StorageKeys.lastSurveyTransmissionDate)
    }
    
    
    /// Gets the date of the latest completed survey from the user document in Firestore, saves it to `UserDefaults` and returns it.
    /// - Returns: The latest survey date as a `String`
    func getLatestSurveyDate() async -> String {
        let document = try? await configuration.userDocumentReference.getDocument()
        
        if let data = document?.data(), let surveyDate = data["latestSurveyDate"] as? String {
            // Update the latest survey date in UserDefaults
            UserDefaults.standard.set(surveyDate, forKey: StorageKeys.lastSurveyDate)
            
            return surveyDate
        } else {
            return ""
        }
    }
    
    func fetchSurveys() async throws -> [DailySurveyResponse] {
        var surveys = [DailySurveyResponse]()
        
        do {
            let snapshot = try await configuration.userDocumentReference
                .collection(Constants.surveyCollectionName)
                .getDocuments()
            
            let decoder = Firestore.Decoder()
            surveys = try snapshot.documents.compactMap { document in
                try decoder.decode(DailySurveyResponse.self, from: document.data())
            }
            .filter {
                $0.surveyDate != nil
            }
        } catch {
            self.logger.error("Error fetching surveys: \(String(describing: error))")
            throw error
        }
        
        return surveys
    }

    /// Returns a reference to a given HealthKit document
    /// - Parameter uuid: The document's unique identifier as a `UUID`.
    /// - Returns: A reference to the document as a `DocumentReference`.
    private func healthKitDocument(id uuid: UUID) async throws -> DocumentReference {
        try await configuration.userDocumentReference
            .collection(Constants.healthKitCollectionName)
            .document(uuid.uuidString)
    }
    
    func deletedAccount() async throws {
        // delete all user associated data
        do {
            try await configuration.userDocumentReference.delete()
        } catch {
            logger.error("Could not delete user document: \(error)")
        }
    }
    
    /// Stores the given consent form in the user's document directory with a unique timestamped filename.
    /// - Parameter consent: The consent form's data to be stored as a `PDFDocument`.
    func store(consent: PDFDocument) async {
        guard !FeatureFlags.disableFirebase else {
            guard let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                logger.error("Could not create path for writing consent form to user document directory.")
                return
            }
            
            let filePath = basePath.appending(path: "consentForm_\(studyID)_consent.pdf")
            consent.write(to: filePath)
            
            return
        }
        
        do {
            guard let consentData = consent.dataRepresentation() else {
                logger.error("Could not store consent form.")
                return
            }
            
            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            _ = try await configuration.userBucketReference
                .child("\(Constants.consentBucketName)/\(studyID)_consent.pdf")
                .putDataAsync(consentData, metadata: metadata)
        } catch {
            logger.error("Could not store consent form: \(error)")
        }
    }
    
    /// Stores the given consent form in the user's document directory and in the consent bucket in Firebase
    /// - Parameter consentData: The consent form's data to be stored.
    /// - Parameter name: The name of the consent document.
    func store(consentData: Data, name: String) async {
        /// Adds the study ID to the file name
        let filename = "\(studyID)_\(name).pdf"
        
        guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logger.error("Could not create path for writing consent form to user document directory.")
            return
        }
        
        let url = docURL.appendingPathComponent(filename)
        
        do {
            try consentData.write(to: url)
            
            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            _ = try await configuration.userBucketReference
                .child("\(Constants.consentBucketName)/\(filename)")
                .putDataAsync(consentData, metadata: metadata)
        } catch {
            logger.error("Could not store consent form: \(error)")
        }
    }
    
    
    /// Check if a consent form with a given name exists in Cloud Storage
    /// - Parameter name: A `String` containing the name of the file to check for existence
    /// - Returns: A `Bool` representing the existence of the file
    func isConsentFormUploaded(name: String) async -> Bool {
        do {
            let maxSize: Int64 = 10 * 1024 * 1024
            let data = try await configuration.userBucketReference
                .child("\(Constants.consentBucketName)/\(studyID)_\(name).pdf")
                .data(maxSize: maxSize)
            
            if let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filename = "\(studyID)_\(name).pdf"
                let url = docURL.appendingPathComponent(filename)
                try? data.write(to: url)
            }
            
            return true
        } catch {
            return false
        }
    }
    
    /// Update the user document with the user's study ID
    func setStudyID(_ studyID: String) async {
        do {
            try await configuration.userDocumentReference.setData(
                [
                    "studyID": studyID
                ],
                merge: true
            )
        } catch {
            logger.error("Unable to set Study ID: \(error)")
        }
    }
    
    /// A helper function to store a current timestamp to `UserDefaults` for a given key.
    /// Used to keep track of the last transmission's timestamp for debugging purposes.
    func storeCurrentTimestamp(forKey key: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        UserDefaults.standard.set(formatter.string(from: Date.now), forKey: key)
    }
}
