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


struct LocationPermissions: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @Environment(LocationModule.self) private var locationModule
    
    @State private var locationProcessing = false
    
    private let logger = Logger(subsystem: "StrokeCog", category: "Onboarding")
    
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "LOCATION_PERMISSIONS_TITLE",
                        subtitle: "LOCATION_PERMISSIONS_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("LOCATION_PERMISSIONS_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            }, actionView: {
                OnboardingActionsView(
                    "LOCATION_PERMISSIONS_BUTTON",
                    action: {
                        do {
                            locationProcessing = true
                            // Location authorization is not available in the preview simulator.
                            if ProcessInfo.processInfo.isPreviewSimulator {
                                try await _Concurrency.Task.sleep(for: .seconds(5))
                                locationProcessing = false
                            } else {
                                locationModule.requestAuthorizationLocation()
                            }
                        } catch {
                            logger.debug("Could not request location permissions.")
                        }
                    }
                )
            }
        )
            .navigationBarBackButtonHidden(locationProcessing)
            .navigationTitle(Text(verbatim: ""))
            .onReceive(locationModule.$authorizationStatus) { status in
                switch status {
                case .authorizedWhenInUse:
                    locationModule.requestAuthorizationLocation()
                case .authorizedAlways:
                    onboardingNavigationPath.nextStep()
                    locationProcessing = false
                default:
                    break
                }
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
