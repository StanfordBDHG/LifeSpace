//
// This source file is part of the LifeSpace application based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import class FirebaseFirestore.FirestoreSettings
import class FirebaseFirestore.MemoryCacheSettings
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirebaseAccountStorage
import SpeziFirebaseStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziScheduler
import SwiftUI


class LifeSpaceDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: LifeSpaceStandard()) {
            if !FeatureFlags.disableFirebase {
                AccountConfiguration(
                    service: FirebaseAccountService(
                        providers: [.signInWithApple],
                        emulatorSettings: accountEmulator
                    ),
                    configuration: [
                        .requires(\.userId)
                    ]
                )
                
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
            
            LifeSpaceScheduler()
            OnboardingDataSource()
            LocationModule()
            LogManager()
        }
    }
    
    private var accountEmulator: (host: String, port: Int)? {
        if FeatureFlags.useFirebaseEmulator {
            (host: "localhost", port: 9099)
        } else {
            nil
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
                    HKQuantityType(.appleStandTime),
                    HKQuantityType(.appleMoveTime),
                    HKCategoryType(.sleepAnalysis)
                ],
                deliverySetting: .background(.automatic)
            )
        }
    }
}
