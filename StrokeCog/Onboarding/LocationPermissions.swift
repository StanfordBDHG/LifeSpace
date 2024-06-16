//
//  LocationPermissions.swift
//  StrokeCog
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
    @State private var currentStep: LocationPermissionsStep = .allowWhileUsingStep
    
    private let logger = Logger(subsystem: "StrokeCog", category: "Onboarding")
    
    enum LocationPermissionsStep {
        case allowWhileUsingStep
        case changeToAlwaysAllowStep
        case changeLocationSettingsStep
    }
    
    var body: some View {
        VStack(spacing: 10) {
            switch currentStep {
            case .allowWhileUsingStep:
                allowWhileUsingStep
            case .changeToAlwaysAllowStep:
                changeToAlwaysAllowStep
            case .changeLocationSettingsStep:
                changeLocationSettingsStep
            }
        }
        .onReceive(locationModule.$authorizationStatus) { status in
            switch status {
            case .authorizedAlways:
                onboardingNavigationPath.nextStep()
            case .authorizedWhenInUse:
                currentStep = .changeToAlwaysAllowStep
            case .denied, .restricted:
                currentStep = .changeLocationSettingsStep
            case .notDetermined:
                currentStep = .allowWhileUsingStep
            @unknown default:
                currentStep = .allowWhileUsingStep
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
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("LOCATION_ALLOW_WHILE_USING_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                }
            },
            actionView: {
                OnboardingActionsView(
                    "LOCATION_PERMISSIONS_BUTTON",
                    action: {
                        locationModule.requestAuthorizationLocation()
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
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("LOCATION_CHANGE_TO_ALWAYS_ALLOW_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                }
            },
            actionView: {
                OnboardingActionsView(
                    "LOCATION_PERMISSIONS_BUTTON",
                    action: {
                        locationModule.requestAuthorizationLocation()
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
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 50))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("LOCATION_CHANGE_LOCATION_SETTINGS_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                }
            },
            actionView: {
                OnboardingActionsView(
                    "LOCATION_PERMISSIONS_BUTTON",
                    action: {
                        guard let settingsUrl = await URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if await UIApplication.shared.canOpenURL(settingsUrl) {
                            await UIApplication.shared.open(settingsUrl)
                        }
                    }
                )
            }
        )
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        LocationPermissions()
    }
}
#endif
