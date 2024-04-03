//
//  LocationPermissions.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/2/24.
//

import SpeziOnboarding
import SpeziScheduler
import SwiftUI


struct LocationPermissions: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @ObservedObject var locationService = LocationService.shared
    
    @State private var locationProcessing = false
    
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "LOCATION_PERMISSIONS_TITLE",
                        subtitle: "LOCATION_PERMISSIONS_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "bell.square.fill")
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
                            // Notification Authorization is not available in the preview simulator.
                            if ProcessInfo.processInfo.isPreviewSimulator {
                                try await _Concurrency.Task.sleep(for: .seconds(5))
                            } else {
                                locationService.requestAuthorizationLocation()
                            }
                        } catch {
                            print("Could not request notification permissions.")
                        }
                        locationProcessing = false
                        
                        onboardingNavigationPath.nextStep()
                    }
                )
            }
        )
            .navigationBarBackButtonHidden(locationProcessing)
            // Small fix as otherwise "Login" or "Sign up" is still shown in the nav bar
            .navigationTitle(Text(verbatim: ""))
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        LocationPermissions()
    }
}
#endif
