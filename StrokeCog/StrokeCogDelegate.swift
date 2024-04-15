//
// This source file is part of the StrokeCog based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirebaseStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziScheduler
import SwiftUI


class StrokeCogDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: StrokeCogStandard()) {
            if !FeatureFlags.disableFirebase {
                AccountConfiguration(configuration: [
                    .requires(\.userId)
                ])

                if FeatureFlags.useFirebaseEmulator {
                    FirebaseAccountConfiguration(
                        authenticationMethods: [.signInWithApple],
                        emulatorSettings: (host: "localhost", port: 9099)
                    )
                } else {
                    FirebaseAccountConfiguration(authenticationMethods: [.signInWithApple])
                }
                firestore
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseStorageConfiguration(emulatorSettings: (host: "localhost", port: 9199))
                } else {
                    FirebaseStorageConfiguration()
                }
            }

            if HKHealthStore.isHealthDataAvailable() {
                healthKit
            }
            
            StrokeCogScheduler()
            OnboardingDataSource()
            LocationModule()
        }
    }
    
    
    private var firestore: Firestore {
        let settings = FirestoreSettings()
        if FeatureFlags.useFirebaseEmulator {
            settings.host = "localhost:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
        }
        
        return Firestore(
            settings: settings
        )
    }
    
    
    private var healthKit: HealthKit {
        HealthKit {
            CollectSamples(
                [
                    HKQuantityType(.stepCount),
                    HKQuantityType(.walkingSpeed),
                    HKQuantityType(.walkingAsymmetryPercentage),
                    HKQuantityType(.appleWalkingSteadiness),
                    HKQuantityType(.stepCount),
                    HKQuantityType(.appleStandTime),
                    HKQuantityType(.appleMoveTime),
                    HKCategoryType(.sleepAnalysis)
                ],
                deliverySetting: .manual()
            )
        }
    }
}
