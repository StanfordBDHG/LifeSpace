//
//  WithdrawView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 8/5/24.
//

import SpeziAccount
import SwiftUI


struct WithdrawView: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @Environment(Account.self) var account
    
    var body: some View {
        Form {
            Section {
                Text("WITHDRAW_VIEW_TEXT")
            }
            
            Section {
                Button(action: {
                    Task {
                        await removeAccount()
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
    }
    
    private func removeAccount() async {
        await account.removeUserDetails()
        completedOnboardingFlow = false
    }
}

#Preview {
    WithdrawView()
}
