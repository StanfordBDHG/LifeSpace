//
// This source file is part of the LifeSpace based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import SpeziAccount
import SwiftUI


struct AccountSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Environment(Account.self) private var account
    @Environment(\.accountRequired) var accountRequired
    @Environment(LocationModule.self) private var locationModule
    
    @State var isInSetup = false
    @State var overviewIsEditing = false
    
    @AppStorage(StorageKeys.studyID) var studyID = "unknownStudyID"
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                if account.signedIn && !isInSetup {
                    AccountOverview(isEditing: $overviewIsEditing) {
                        optionsList
                    }
                        .onDisappear {
                            overviewIsEditing = false
                        }
                        .toolbar {
                            if !overviewIsEditing {
                                closeButton
                            }
                        }
                } else {
                    VStack {
                        AccountSetupHeader()
                        AccountSetup { _ in
                            dismiss() // we just signed in, dismiss the account setup sheet
                        }
                    }
                        .onAppear {
                            isInSetup = true
                        }
                        .toolbar {
                            if !accountRequired {
                                closeButton
                            }
                        }
                }
            }
        }
    }
    
    private var optionsList: some View {
        List {
            Section(header: Text("STUDYID_SECTION")) {
                Text(studyID)
            }
            Section(header: Text("DOCUMENTS_SECTION")) {
                consentDocumentButton
                hipaaAuthorizationDocumentButton
                privacyPolicyButton
            }
            Section(header: Text("SETTINGS_SECTION")) {
               locationTrackingToggle
            }
        }
    }
    
    private var consentDocumentButton: some View {
        NavigationLink(destination: {
            if let url = getDocumentURL(for: "consent") {
                ConsentPDFViewer(url: url)
            } else {
                Text("DOCUMENT_NOT_FOUND_MESSAGE")
            }
        }) {
            Text("VIEW_CONSENT_DOCUMENT")
        }
    }
    
    private var hipaaAuthorizationDocumentButton: some View {
        NavigationLink(destination: {
            if let url = getDocumentURL(for: "hipaaAuthorization") {
                ConsentPDFViewer(url: url)
            } else {
                Text("DOCUMENT_NOT_FOUND_MESSAGE")
            }
        }) {
            Text("VIEW_HIPAA_AUTHORIZATION")
        }
    }
    
    private var privacyPolicyButton: some View {
        NavigationLink(destination: {
            if let url = URL(string: "https://michelleodden.com/cardinal-lifespace-privacy-policy/") {
                DocumentWebView(url: url)
            } else {
                Text("DOCUMENT_NOT_FOUND_MESSAGE")
            }
        }) {
            Text("VIEW_PRIVACY_POLICY")
        }
    }
    
    private var locationTrackingToggle: some View {
        Toggle("TRACK_LOCATION_BUTTON", isOn: $trackingOn)
            .onChange(of: trackingOn) {
                if trackingOn {
                    locationModule.startTracking()
                } else {
                    locationModule.stopTracking()
                }
            }
    }

    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("CLOSE") {
                dismiss()
            }
        }
    }

    
    private func getDocumentURL(for fileName: String) -> URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let filenameWithStudyID = "\(studyID)_\(fileName).pdf"
        return documentsURL.appendingPathComponent(filenameWithStudyID)
    }
}


#if DEBUG
#Preview("AccountSheet") {
    let details = AccountDetails.Builder()
        .set(\.userId, value: "lelandstanford@stanford.edu")
        .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))
    
    return AccountSheet()
        .previewWith {
            AccountConfiguration(building: details, active: MockUserIdPasswordAccountService())
        }
}

#Preview("AccountSheet SignIn") {
    AccountSheet()
        .previewWith {
            AccountConfiguration {
                MockUserIdPasswordAccountService()
            }
        }
}
#endif
