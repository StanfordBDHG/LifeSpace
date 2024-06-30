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
    
    @State var isInSetup = false
    @State var overviewIsEditing = false
    
    @AppStorage(StorageKeys.studyID) var studyID = "unknownStudyID"
    
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
    
    var optionsList: some View {
        List {
            Section(header: Text("STUDYID_SECTION")) {
                Text(studyID)
            }
            Section(header: Text("DOCUMENTS_SECTION")) {
                NavigationLink(destination: {
                    if let url = getDocumentURL(for: "consent") {
                        ConsentPDFViewer(url: url)
                    } else {
                        Text("DOCUMENT_NOT_FOUND_MESSAGE")
                    }
                }) {
                    Text("VIEW_CONSENT_DOCUMENT")
                }
                NavigationLink(destination: {
                    if let url = getDocumentURL(for: "hipaaAuthorization") {
                        ConsentPDFViewer(url: url)
                    } else {
                        Text("DOCUMENT_NOT_FOUND_MESSAGE")
                    }
                }) {
                    Text("VIEW_HIPAA_AUTHORIZATION")
                }
                NavigationLink(destination: EmptyView()) {
                    Button(action: {
                        if let url = URL(string: "https://michelleodden.com/cardinal-lifespace-privacy-policy/") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("VIEW_PRIVACY_POLICY")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("CLOSE") {
                dismiss()
            }
        }
    }

    
    func getDocumentURL(for fileName: String) -> URL? {
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
