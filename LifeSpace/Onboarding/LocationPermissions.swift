//
//  LocationPermissions.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/2/24.
//

import OSLog
import SpeziOnboarding
import SpeziScheduler
import SwiftUI


// swiftlint:disable type_contents_order
struct LocationPermissions: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @Environment(LocationModule.self) private var locationModule
    
    @State private var locationProcessing = false
    @State private var currentStep: LocationPermissionsStep = .allowWhileUsing
    
    @AppStorage(StorageKeys.isFirstLocationRequest) var isFirstRequest = true
    
    private let logger = Logger(subsystem: "LifeSpace", category: "Onboarding")
    
    enum LocationPermissionsStep {
        case allowWhileUsing
        case changeToAlwaysAllow
        case changeLocationSettings
    }
    
    var body: some View {
        VStack(spacing: 10) {
            switch currentStep {
            case .allowWhileUsing:
                allowWhileUsingStep
            case .changeToAlwaysAllow:
                changeToAlwaysAllowStep
            case .changeLocationSettings:
                changeLocationSettingsStep
            }
        }
        .onReceive(locationModule.$authorizationStatus) { status in
            switch status {
            case .authorizedAlways:
                onboardingNavigationPath.nextStep()
            case .authorizedWhenInUse:
                if isFirstRequest {
                    isFirstRequest = false
                    currentStep = .changeToAlwaysAllow
                } else {
                    currentStep = .changeLocationSettings
                }
            case .denied, .restricted:
                isFirstRequest = false
                currentStep = .changeLocationSettings
            case .notDetermined:
                isFirstRequest = true
                currentStep = .allowWhileUsing
            @unknown default:
                currentStep = .changeLocationSettings
            }
        }
    }
    
    var allowWhileUsingStep: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "LOCATION_PERMISSIONS_TITLE",
                        subtitle: "LOCATION_PERMISSIONS_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "map.circle.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("LOCATION_ALLOW_WHILE_USING_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            },
            actionView: {
                OnboardingActionsView(
                    primaryText: "LOCATION_PERMISSIONS_BUTTON",
                    primaryAction: {
                        locationModule.requestAuthorizationLocation()
                    },
                    secondaryText: "LOCATION_NO_POPUP_BUTTON",
                    secondaryAction: {
                        currentStep = .changeLocationSettings
                    }
                )
            }
        )
    }
    
    var changeToAlwaysAllowStep: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "LOCATION_PERMISSIONS_TITLE",
                        subtitle: "LOCATION_PERMISSIONS_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "map.circle.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("LOCATION_CHANGE_TO_ALWAYS_ALLOW_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            },
            actionView: {
                OnboardingActionsView(
                    primaryText: "LOCATION_PERMISSIONS_BUTTON",
                    primaryAction: {
                        locationModule.requestAuthorizationLocation()
                    },
                    secondaryText: "LOCATION_NO_POPUP_BUTTON",
                    secondaryAction: {
                        currentStep = .changeLocationSettings
                    }
                )
            }
        )
    }
    
    var changeLocationSettingsStep: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "LOCATION_PERMISSIONS_TITLE",
                        subtitle: "LOCATION_PERMISSIONS_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "map.circle.fill")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("LOCATION_CHANGE_LOCATION_SETTINGS_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            },
            actionView: {
                OnboardingActionsView(
                    "LOCATION_PERMISSIONS_BUTTON",
                    action: {
                        await openLocationSettings()
                    }
                )
            }
        )
    }
    
    @MainActor
    func openLocationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        LocationPermissions()
    }
}
#endif
