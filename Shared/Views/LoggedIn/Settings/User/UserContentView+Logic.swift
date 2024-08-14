//
//  UserContentView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 26/5/22.
//

import SwiftUI

// MARK: - Logout

internal extension UserContentView {
    
    func logout() {
        appData.logout()
        deviceData.disconnectAll()
    }
}

// MARK: - Delete User Account

struct DeleteUserAlertModifier: ViewModifier {

    let user: User
    @Binding var showingDeleteUserAccountAlert: Bool
    @Binding var deleteUserPassword: String
    @Binding var deleteUserTotpToken: String
    private let onCancel: () -> Void
    private let onDelete: () -> Void
    
    init(user: User, showingDeleteUserAccountAlert: Binding<Bool>,
         deleteUserPassword: Binding<String>, deleteUserTotpToken: Binding<String>,
         onCancel: @escaping () -> Void,
         onDelete: @escaping () -> Void) {
        self.user = user
        _showingDeleteUserAccountAlert = showingDeleteUserAccountAlert
        _deleteUserPassword = deleteUserPassword
        _deleteUserTotpToken = deleteUserTotpToken
        self.onCancel = onCancel
        self.onDelete = onDelete
    }
    
    func body(content: Content) -> some View {
        content
            .alert(Strings.deleteUserAccount,
                   isPresented: $showingDeleteUserAccountAlert) {
                Button("Cancel", role: .cancel, action: onCancel)
                
                Button("Delete", role: .destructive, action: onDelete)
        
                TextField("Password", text: $deleteUserPassword)
                    .textContentType(.password)
        
                if user.mfaConfigured {
                    TextField("Authenticator Code", text: $deleteUserTotpToken)
                        .textContentType(.oneTimeCode)
                }
            } message: {
                Text(Strings.deleteUserAccountDescription)
            }
    }
}

internal extension UserContentView {
    
    func alertViewModifier(for user: User) -> DeleteUserAlertModifier {
        DeleteUserAlertModifier(user: user, showingDeleteUserAccountAlert: $showingDeleteUserAccountAlert, deleteUserPassword: $deleteUserPassword, deleteUserTotpToken: $deleteUserTotpToken, onCancel: {
            dismissDeleteUserAccount()
        }, onDelete: {
            dismissDeleteUserAccount()
            confirmDeleteUserAccount(with: deleteUserPassword,
                                     and: deleteUserTotpToken)
        })
    }
    
    func showDeleteUserAccountAlert() {
        deleteUserPassword = ""
        deleteUserTotpToken = ""
        showingDeleteUserAccountAlert = true
    }
    
    func confirmDeleteUserAccount(with password: String, and totpToken: String) {
        showingDeleteUserAccountAlert = false
        appData.deleteUserAccount(with: password, and: totpToken)
    }
    
    func dismissDeleteUserAccount() {
        showingDeleteUserAccountAlert = false
    }
}
