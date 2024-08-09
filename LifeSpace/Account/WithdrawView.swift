//
//  WithdrawView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 8/5/24.
//

import FirebaseAuth
import SpeziAccount
import SwiftUI


struct WithdrawView: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @AppStorage(StorageKeys.studyID) var studyID = "unknownStudyID"

    @Environment(Account.self) var account
    @Environment(LocationModule.self) private var locationModule
    
    @State private var showingAlert = false
    @State private var showingDeleteSheet = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section {
                Text("WITHDRAW_VIEW_TEXT")
            }
            
            Section {
                Button(action: {
                    Task {
                        await processWithdrawal()
                    }
                }, label: {
                    Text("WITHDRAW")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                })
                .buttonStyle(.borderedProminent)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .navigationTitle("WITHDRAW_VIEW_TITLE")
        .sheet(isPresented: $showingDeleteSheet) {
           deleteInstructionView
                .interactiveDismissDisabled()
        }
        .alert("LOG_OUT_ERROR", isPresented: $showingAlert) {
            Button("OK") { }
        }
    }
    
    private var deleteInstructionView: some View {
        VStack {
            Spacer()
            
            Text("APP_DELETION_INSTRUCTION")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)

            Spacer()

            Button(action: {
                // Send user back to onboarding flow
                completedOnboardingFlow = false
            }, label: {
                Text("CLOSE")
                    .padding()
            })
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
    
    private func processWithdrawal() async {
        // Stop location tracking
        locationModule.stopTracking()
        UserDefaults.standard.set(false, forKey: Constants.prefTrackingStatus)
        
        // Clear the user's study ID
        studyID = ""
        
        // Sign out the user
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
            self.showingAlert = true
        }
        
        // Remove the user's account
        await account.removeUserDetails()
        
        // Instruct the user to delete the app
        self.showingDeleteSheet = true
    }
}

#Preview {
    WithdrawView()
}
