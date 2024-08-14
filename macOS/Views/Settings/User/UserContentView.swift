//
//  UserContentView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 26/5/22.
//

import SwiftUI

// MARK: - UserContentView

struct UserContentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: Private
    
    @State internal var deleteUserPassword = ""
    @State internal var deleteUserTotpToken = ""
    @State internal var showingDeleteUserAccountAlert = false
    
    // MARK: View
    
    var body: some View {
        if let user = appData.user {
            List {
                Section(header: Text("User")) {
                    UserView(user: user)
                        .withTabBarStyle()
                }
                
                Section(header: Text("Projects")) {
                    if appData.projects.isEmpty {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "moon.stars.fill")
                                .resizable()
                                .frame(width: 60, height: 60, alignment: .center)
                                .foregroundColor(.nordicBlueslate)
                            Text("Your Project List is empty.")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    ForEach(appData.projects) { project in
                        NavigationLink(destination: ProjectView(project)) {
                            ProjectRow(project)
                        }
                    }
                }
                
                Section {
                    MultiColumnView {
                        Button("Logout", action: logout)
                        
                        Text(Strings.logoutFooter)
                            .font(.callout)
                            .foregroundColor(.nordicMiddleGrey)
                    }
                    .withTabBarStyle()
                    
                    MultiColumnView {
                        Button("Delete", action: showDeleteUserAccountAlert)
                            .foregroundColor(.negativeActionButtonColor)
                        
                        Text(Strings.accountDeletionFooter)
                            .foregroundColor(.nordicMiddleGrey)
                            .font(.callout)
                    }
                    .withTabBarStyle()
                } header: {
                    Text("Account")
                }
            }
            .setTitle("User")
            .alert(Strings.deleteUserAccount,
                   isPresented: $showingDeleteUserAccountAlert) {
                Button("Cancel", role: .cancel) {
                    dismissDeleteUserAccount()
                    deleteUserPassword = ""
                    deleteUserTotpToken = ""
                }
                
                Button("Delete", role: .destructive) {
                    dismissDeleteUserAccount()
                    confirmDeleteUserAccount(with: deleteUserPassword,
                                             and: deleteUserTotpToken)
                }
                
                TextField("Password", text: $deleteUserPassword)
                    .textContentType(.password)
                
                if user.mfaConfigured {
                    TextField("Authenticator Code", text: $deleteUserTotpToken)
                        .textContentType(.oneTimeCode)
                }
            } message: {
                Text(Strings.deleteUserAccountDescription)
            }
        } else {
            EmptyView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct UserContentView_Previews: PreviewProvider {
    static var previews: some View {
        UserContentView()
    }
}
#endif
