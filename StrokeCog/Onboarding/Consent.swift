//
// This source file is part of the StrokeCog based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OSLog
import ResearchKit
import ResearchKitSwiftUI
import SpeziOnboarding
import SwiftUI


struct Consent: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @Environment(StrokeCogStandard.self) private var standard
    
    private let logger = Logger(subsystem: "StrokeCog", category: "Standard")
    
    @State private var isConsentSheetPresented = false
    @State private var savingConsentForms = false
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "CONSENT_TITLE",
                        subtitle: "CONSENT_SUBTITLE"
                    )
                    Spacer()
                    Image(systemName: "doc")
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("CONSENT_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            },
            actionView: {
                OnboardingActionsView("CONSENT_BUTTON") {
                    isConsentSheetPresented = true
                }
            }
        )
        .sheet(isPresented: $isConsentSheetPresented) {
            ORKOrderedTaskView(tasks: consentTask) { result in
                self.savingConsentForms = true
                
                guard case let .completed(taskResult) = result else {
                    self.savingConsentForms = false
                    self.isConsentSheetPresented = false
                    return // user cancelled or task failed
                }
                
                await saveConsentForms(taskResult)
                
                self.savingConsentForms = false
                self.isConsentSheetPresented = false
                onboardingNavigationPath.nextStep()
            }
            .overlay {
                if savingConsentForms {
                    savingProgressView
                }
            }
            .ignoresSafeArea(edges: .all)
            .interactiveDismissDisabled(true)
        }
        .onAppear {
            isConsentSheetPresented = true
        }
    }
    
    var savingProgressView: some View {
        VStack {
            Text("CONSENT_PROGRESS")
            ProgressView()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(.rect(cornerRadius: 10))
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
    
    @MainActor
    func saveConsentForms(_ taskResult: ORKTaskResult) async {
        guard let signatureResult = taskResult
            .stepResult(forStepIdentifier: "ConsentReviewStep")?.results?.first as? ORKConsentSignatureResult,
              let hipaaSignatureResult = taskResult
            .stepResult(forStepIdentifier: "HIPAAAuthorizationReviewStep")?.results?.first as? ORKConsentSignatureResult,
              signatureResult.consented,
              hipaaSignatureResult.consented else {
            // user did not consent
            self.isConsentSheetPresented = false
            return
        }
        
        let consentDocument = LifeSpaceConsent()
        signatureResult.apply(to: consentDocument)
        
        let hipaaConsentDocument = HIPAAAuthorization()
        hipaaSignatureResult.apply(to: hipaaConsentDocument)
        
        do {
            let consentPDFData = try await consentDocument.makePDF()
            await standard.store(consentData: consentPDFData, name: "consent")
            
            let hipaaPDFData = try await hipaaConsentDocument.makePDF()
            await standard.store(consentData: hipaaPDFData, name: "hipaaAuthorization")
        } catch {
            logger.error("Unable to generate PDF: \(error)")
        }
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
