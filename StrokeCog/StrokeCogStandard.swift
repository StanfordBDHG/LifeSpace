//
// This source file is part of the StrokeCog based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CoreLocation
import FirebaseFirestore
import FirebaseStorage
import HealthKitOnFHIR
import OSLog
import PDFKit
import Spezi
import SpeziAccount
import SpeziFirebaseAccountStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI


actor StrokeCogStandard: Standard, EnvironmentAccessible, HealthKitConstraint, OnboardingConstraint, AccountStorageConstraint {
    enum StrokeCogStandardError: Error {
        case userNotAuthenticatedYet
    }

    private static var userCollection: CollectionReference {
        Firestore.firestore().collection("users")
    }

    @Dependency var accountStorage: FirestoreAccountStorage?

    @AccountReference var account: Account

    private let logger = Logger(subsystem: "StrokeCog", category: "Standard")
    
    
    private var userDocumentReference: DocumentReference {
        get async throws {
            guard let details = await account.details else {
                throw StrokeCogStandardError.userNotAuthenticatedYet
            }

            return Self.userCollection.document(details.accountId)
        }
    }
    
    private var userBucketReference: StorageReference {
        get async throws {
            guard let details = await account.details else {
                throw StrokeCogStandardError.userNotAuthenticatedYet
            }

            return Storage.storage().reference().child("users/\(details.accountId)")
        }
    }


    init() {
        if !FeatureFlags.disableFirebase {
            _accountStorage = Dependency(wrappedValue: FirestoreAccountStorage(storeIn: StrokeCogStandard.userCollection))
        }
    }


    func add(sample: HKSample) async {
        do {
            try await healthKitDocument(id: sample.id).setData(from: sample.resource)
        } catch {
            logger.error("Could not store HealthKit sample: \(error)")
        }
    }
    
    func remove(sample: HKDeletedObject) async {
        do {
            try await healthKitDocument(id: sample.uuid).delete()
        } catch {
            logger.error("Could not remove HealthKit sample: \(error)")
        }
    }
    
    func add(response: ModelsR4.QuestionnaireResponse) async {
        let id = response.identifier?.value?.value?.string ?? UUID().uuidString
    
        do {
            try await userDocumentReference
                .collection("QuestionnaireResponse") // Add all HealthKit sources in a /QuestionnaireResponse collection.
                .document(id) // Set the document identifier to the id of the response.
                .setData(from: response)
        } catch {
            logger.error("Could not store questionnaire response: \(error)")
        }
    }
    
    func add(location: CLLocationCoordinate2D) async throws {
        guard let details = await account.details else {
            throw StrokeCogStandardError.userNotAuthenticatedYet
        }
        
        let dataPoint = LocationDataPoint(
            currentDate: Date(),
            time: Date().timeIntervalSince1970,
            latitude: location.latitude,
            longitude: location.longitude,
            studyID: details.userId,
            updatedBy: details.accountId
        )
        
        try await userDocumentReference
            .collection("location_data")
            .document(UUID().uuidString)
            .setData(from: dataPoint)
    }
    
    func fetchLocations(on date: Date = Date()) async throws -> [CLLocationCoordinate2D] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)
        
        var locations = [CLLocationCoordinate2D]()
        
        do {
            let snapshot = try await userDocumentReference
                .collection("location_data")
                .whereField("currentDate", isGreaterThanOrEqualTo: startOfDay)
                .whereField("currentDate", isLessThan: endOfDay ?? Date())
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

    
    func add(response: DailySurveyResponse) async throws {
        guard let details = await account.details else {
            throw StrokeCogStandardError.userNotAuthenticatedYet
        }
        
        try await userDocumentReference
            .collection("surveys")
            .document(UUID().uuidString)
            .setData(from: response)
    }
    
    
    private func healthKitDocument(id uuid: UUID) async throws -> DocumentReference {
        try await userDocumentReference
            .collection("HealthKit") // Add all HealthKit sources in a /HealthKit collection.
            .document(uuid.uuidString) // Set the document identifier to the UUID of the document.
    }

    func deletedAccount() async throws {
        // delete all user associated data
        do {
            try await userDocumentReference.delete()
        } catch {
            logger.error("Could not delete user document: \(error)")
        }
    }
    
    /// Stores the given consent form in the user's document directory with a unique timestamped filename.
    ///
    /// - Parameter consent: The consent form's data to be stored as a `PDFDocument`.
    func store(consent: PDFDocument) async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = formatter.string(from: Date())
        
        guard !FeatureFlags.disableFirebase else {
            guard let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                logger.error("Could not create path for writing consent form to user document directory.")
                return
            }
            
            let filePath = basePath.appending(path: "consentForm_\(dateString).pdf")
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
            _ = try await userBucketReference.child("consent/\(dateString).pdf").putDataAsync(consentData, metadata: metadata)
        } catch {
            logger.error("Could not store consent form: \(error)")
        }
    }


    func create(_ identifier: AdditionalRecordId, _ details: SignupDetails) async throws {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        try await accountStorage.create(identifier, details)
    }

    func load(_ identifier: AdditionalRecordId, _ keys: [any AccountKey.Type]) async throws -> PartialAccountDetails {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        return try await accountStorage.load(identifier, keys)
    }

    func modify(_ identifier: AdditionalRecordId, _ modifications: AccountModifications) async throws {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        try await accountStorage.modify(identifier, modifications)
    }

    func clear(_ identifier: AdditionalRecordId) async {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        await accountStorage.clear(identifier)
    }

    func delete(_ identifier: AdditionalRecordId) async throws {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        try await accountStorage.delete(identifier)
    }
}
