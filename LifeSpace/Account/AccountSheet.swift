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
    
    //swiftlint:disable closure_body_length
    var body: some View {
        NavigationStack {
            ZStack {
                if account.signedIn && !isInSetup {
                    AccountOverview(isEditing: $overviewIsEditing
                    ) {
                        List {
                            Section(header: Text("Study ID")) {
                                Text("\(getStudyID())")
                            }
                            Section(header: Text("Documents")) {
                                NavigationLink(destination: PDFViewWrapper(url: getDocumentURL(for: "consent"))) {
                                    Text("View Consent Document")
                                }
                                NavigationLink(destination: PDFViewWrapper(url: getDocumentURL(for: "hipaaAuthorization"))) {
                                    Text("View HIPAA Authorization")
                                }
                            }
                        }
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

    var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("CLOSE") {
                dismiss()
            }
        }
    }
    
    func getStudyID() -> String {
        UserDefaults.standard.string(forKey: StorageKeys.studyID) ?? "unknownStudyID"
    }
    
    func getDocumentURL(for fileName: String) -> URL {
        let studyID = getStudyID()
        let filename = "\(studyID)_\(fileName).pdf"
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        return fileURL
    }
}


struct PDFViewWrapper: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
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
