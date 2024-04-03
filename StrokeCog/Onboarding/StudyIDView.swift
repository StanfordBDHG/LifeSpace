//
//  StudyIDView.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 3/30/24.
//

import SpeziOnboarding
import SpeziValidation
import SpeziViews
import SwiftUI

struct StudyIDView: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @State private var studyID = ""
    @State private var showInvalidIDAlert = false
    @ValidationState private var validation
    
    var body: some View {
        VStack(spacing: 32) {
            OnboardingView(
                titleView: {
                    OnboardingTitleView(
                        title: "STUDYID_TITLE",
                        subtitle: "STUDYID_SUBTITLE"
                    )
                },
                contentView: {
                    studyIDEntryView
                },
                actionView: {
                    OnboardingActionsView(
                        "Next",
                        action: {
                            guard validation.validateSubviews() else {
                                return
                            }
                            
                            if verify(id: studyID) {
                                onboardingNavigationPath.nextStep()
                            } else {
                                showInvalidIDAlert = true
                            }
                        }
                    )
                }
            )
        }
    }
    
    @ViewBuilder private var studyIDEntryView: some View {
        VerifiableTextField(
            LocalizedStringResource("STUDYID_TEXT_FIELD_LABEL"),
            text: $studyID
        )
        .autocorrectionDisabled()
        .textInputAutocapitalization(.characters)
        .textContentType(.oneTimeCode)
        .validate(input: studyID, rules: [validationRule])
        .receiveValidation(in: $validation)
        .alert(
            "Error",
            isPresented: $showInvalidIDAlert
        ) {
            Text("INVALID_STUDYID_MESSAGE")
            Button("RETRY_BUTTON_LABEL") { }
        }
    }
    
    private var validationRule: ValidationRule {
        ValidationRule(
            rule: { studyID in
                studyID.count >= 4
            },
            message: "A study ID should be at least 4 characters long."
        )
    }
    
    private func verify(id: String) -> Bool {
        var validStudyIDs = [String]()
        
        if let studyIDsURL = Bundle.main.url(forResource: "studyIDs", withExtension: ".csv"),
           let studyIDs = try? String(contentsOf: studyIDsURL) {
            let allStudyIDs = studyIDs.components(separatedBy: "\n")
            
            for studyID in allStudyIDs {
                validStudyIDs.append(studyID.filter { !$0.isWhitespace })
            }
            
            return validStudyIDs.contains(id)
        }
        return false
    }
}

#Preview {
    StudyIDView()
}
