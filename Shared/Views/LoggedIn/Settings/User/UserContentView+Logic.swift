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

internal extension UserContentView {
    
    func showDeleteUserAccountAlert() {
        showingDeleteUserAccountAlert = true
    }
    
    func deleteUserAccountAlert() -> Alert {
        Alert(title: Text(Strings.deleteUserAccount),
              message: Text(Strings.deleteUserAccountDescription),
              primaryButton: .destructive(Text("Yes"), action: confirmDeleteUserAccount),
              secondaryButton: .default(Text("Cancel"), action: dismissDeleteUserAccount))
    }
    
    func confirmDeleteUserAccount() {
        showingDeleteUserAccountAlert = false
        appData.deleteUserAccount()
    }
    
    func dismissDeleteUserAccount() {
        showingDeleteUserAccountAlert = false
    }
}
