//
//  FirebaseConfiguration.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 11/1/24.
//

import FirebaseFirestore
import FirebaseStorage
import Spezi
import SpeziAccount
import SpeziFirebaseAccount


final class FirebaseConfiguration: Module, DefaultInitializable, @unchecked Sendable {
    enum ConfigurationError: Error {
        case userNotAuthenticatedYet
    }

    static var userCollection: CollectionReference {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? Constants.defaultBundleIdentifier
        return Firestore.firestore().collection(bundleIdentifier).document("study").collection(Constants.userCollectionName)
    }


    @MainActor var userDocumentReference: DocumentReference {
        get throws {
            guard let details = account?.details else {
                throw ConfigurationError.userNotAuthenticatedYet
            }

            return userDocumentReference(for: details.accountId)
        }
    }

    @MainActor var userBucketReference: StorageReference {
        get throws {
            guard let details = account?.details else {
                throw ConfigurationError.userNotAuthenticatedYet
            }

            let bundleIdentifier = Bundle.main.bundleIdentifier ?? Constants.defaultBundleIdentifier
            return Storage.storage().reference().child("\(bundleIdentifier)/study/\(Constants.userCollectionName)/\(details.accountId)")
        }
    }

    @Application(\.logger) private var logger

    @Dependency(Account.self) private var account: Account? // optional, as Firebase might be disabled
    @Dependency(FirebaseAccountService.self) private var accountService: FirebaseAccountService?

    init() {}

    func userDocumentReference(for accountId: String) -> DocumentReference {
        Self.userCollection.document(accountId)
    }


    func configure() {
        Task {
            await setupTestAccount()
        }
    }


    private func setupTestAccount() async {
        guard let accountService, FeatureFlags.setupTestAccount else {
            return
        }

        do {
            try await accountService.login(userId: "lelandstanford@stanford.edu", password: "StanfordRocks!")
            return
        } catch {
            guard let accountError = error as? FirebaseAccountError,
                  case .invalidCredentials = accountError else {
                logger.error("Failed to login into test account: \(error)")
                return
            }
        }

        /// account doesn't exist yet, signup
        var details = AccountDetails()
        details.userId = "lelandstanford@stanford.edu"
        details.password = "StanfordRocks!"
        details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
        details.genderIdentity = .male

        do {
            try await accountService.signUp(with: details)
        } catch {
            logger.error("Failed to setup test account: \(error)")
        }
    }
}
