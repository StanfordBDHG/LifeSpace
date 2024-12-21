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


private struct AccountHeader: View {
    @Environment(Account.self) var account
    
    var body: some View {
        VStack {
            profileImage
            if let email = account.details?.email {
                Text(email)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    private var profileImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .frame(width: 60, height: 60)
            .foregroundColor(Color(.systemGray3))
            .accessibilityHidden(true)
    }
}

struct AccountSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Environment(Account.self) private var account
    @Environment(\.accountRequired) var accountRequired
    @Environment(LocationModule.self) private var locationModule
    
    @State var isInSetup = false
    @State var overviewIsEditing = false
    
    @AppStorage(StorageKeys.studyID) var studyID = "unknownStudyID"
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    @AppStorage(StorageKeys.lastSurveyTransmissionDate) private var lastSurveyTransmissionDate = "Not set"
    @AppStorage(StorageKeys.lastLocationTransmissionDate) private var lastLocationTransmissionDate = "Not set"
    
    var body: some View {
        NavigationStack {
            ZStack {
                if account.signedIn && !isInSetup {
                    Form {
                        AccountHeader()
                        optionsList
                    }
                    .padding(.top, -20)
                    .toolbar {
                        closeButton
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
    
    private var profileImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .frame(width: 60, height: 60)
            .foregroundColor(Color(.systemGray3))
            .accessibilityHidden(true)
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
                withdrawButton
            }
            if FeatureFlags.showDebugOptions {
                Section(header: Text("DEBUG_SECTION")) {
                    logExportButton
                }
                Section(header: Text("LAST_SURVEY_TRANSMISSION_SECTION")) {
                    Text(lastSurveyTransmissionDate)
                }
                Section(header: Text("LAST_LOCATION_TRANSMISSION_SECTION")) {
                    Text(lastLocationTransmissionDate)
                }
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
            if let url = URL(string: Constants.privacyPolicyURL) {
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
    
    private var withdrawButton: some View {
        NavigationLink(destination: {
            WithdrawView()
        }) {
            Text("WITHDRAW")
        }
    }
    
    private var closeButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("CLOSE") {
                dismiss()
            }
        }
    }
    
    private var logExportButton: some View {
        NavigationLink(destination: {
            LogViewer()
        }) {
            Text("VIEW_LOGS")
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
