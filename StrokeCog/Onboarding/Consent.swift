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


// swiftlint:disable closure_body_length
struct Consent: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @Environment(StrokeCogStandard.self) private var standard
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
                
                if let signatureResult = taskResult
                    .stepResult(forStepIdentifier: "ConsentReviewStep")?.results?.first as? ORKConsentSignatureResult {
                    let consentDocument = LifeSpaceConsent()
                    signatureResult.apply(to: consentDocument)
                    
                    consentDocument.makePDF { data, _ -> Void in
                        guard let data else {
                            return
                        }
                        
                        Task {
                            await standard.store(consentData: data, filename: "consent.pdf")
                        }
                    }
                }
                
                if let hipaaSignatureResult = taskResult
                    .stepResult(forStepIdentifier: "HIPAAAuthorizationReviewStep")?.results?.first as? ORKConsentSignatureResult {
                    let consentDocument = HIPAAAuthorization()
                    hipaaSignatureResult.apply(to: consentDocument)
                    
                    consentDocument.makePDF { data, _ -> Void in
                        guard let data else {
                            return
                        }
                        
                        Task {
                            await standard.store(consentData: data, filename: "hipaaAuthorization.pdf")
                        }
                    }
                }

                self.isConsentSheetPresented = false
                onboardingNavigationPath.nextStep()
            }
            .ignoresSafeArea(edges: .all)
            .interactiveDismissDisabled(true)
        }
        .onAppear {
            isConsentSheetPresented = true
        }
    }
    
    var consentTask: ORKOrderedTask {
        let consentInstructionStep = ORKInstructionStep(identifier: "ConsentInstructionStep")
        consentInstructionStep.title = "Study Consent"
        consentInstructionStep.detailText = """
        In the next two steps you will be asked to review and sign two consent forms for the LifeSpace study.
        
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
        reviewHIPAAAuthorizationStep.reasonForConsent = "Consent to share your health information for research purposes."
        
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
