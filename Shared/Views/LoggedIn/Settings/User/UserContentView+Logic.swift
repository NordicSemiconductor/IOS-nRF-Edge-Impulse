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
