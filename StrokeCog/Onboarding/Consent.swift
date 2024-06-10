//
// This source file is part of the StrokeCog based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ResearchKit
import ResearchKitSwiftUI
import SpeziOnboarding
import SwiftUI


struct Consent: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @State private var isConsentSheetPresented = false

    var body: some View {
        Button(action: {
            isConsentSheetPresented = true
        }) {
            Text("Show Consent")
        }
        .sheet(isPresented: $isConsentSheetPresented) {
            ORKOrderedTaskView(tasks: consentTask) { result in
                guard case let .completed(taskResult) = result else {
                    self.isConsentSheetPresented = false
                    return // user cancelled or task failed
                }

                self.isConsentSheetPresented = false
                onboardingNavigationPath.nextStep()
            }
            .ignoresSafeArea(edges: .all)
        }
        .onAppear {
            isConsentSheetPresented = true
        }
    }
    
    var consentTask: ORKOrderedTask {
        let consentInstructionStep = ORKInstructionStep(identifier: "ConsentInstructionStep")
        consentInstructionStep.title = "Study Consent"
        consentInstructionStep.detailText = """
        In the next two steps you will be asked to review two consent forms the LifeSpace study. 
        
        Please read the forms carefully and sign if you agree to the terms.
        """
        
        let consentDocument = LifeSpaceConsent()
        let signature = consentDocument.signatures?.first
        
        let hipaaAuthorizationDocument = HIPAAAuthorization()
        let hipaaSignature = hipaaAuthorizationDocument.signatures?.first
        
        let reviewConsentStep = ORKConsentReviewStep(
            identifier: "ConsentReviewStep",
            signature: signature,
            in: consentDocument
        )
        reviewConsentStep.text = "Review Consent Form"
        reviewConsentStep.reasonForConsent = "Consent to join the LifeSpace Study."
        
        let reviewHIPAAAuthorizationStep = ORKConsentReviewStep(
            identifier: "HIPAAAuthorizationReviewStep",
            signature: hipaaSignature,
            in: hipaaAuthorizationDocument
        )
        reviewHIPAAAuthorizationStep.text = "Review Consent Form"
        reviewHIPAAAuthorizationStep.reasonForConsent = "Consent to join the LifeSpace Study."
        
        let steps = [consentInstructionStep, reviewConsentStep, reviewHIPAAAuthorizationStep]
        
        return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        Consent()
    }
        .previewWith(standard: StrokeCogStandard()) {
            OnboardingDataSource()
        }
}
#endif
