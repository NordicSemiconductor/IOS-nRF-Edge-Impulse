//
//  UserContentView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 26/5/22.
//

import SwiftUI

struct UserContentView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - Private
    
    @State internal var showingDeleteUserAccountAlert = false
    
    // MARK: - View
    
    var body: some View {
        switch appData.loginState {
        case .complete(let user, let projects):
            VStack {
                HeroView(user: user)
                    .padding()
                
                List {
                    Section(header: Text("Projects")) {
                        if projects.isEmpty {
                            VStack(alignment: .center, spacing: 16) {
                                Image(systemName: "moon.stars.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60, alignment: .center)
                                    .foregroundColor(Assets.blueslate.color)
                                Text("Your Project List is empty.")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        ForEach(projects) { project in
                            NavigationLink(destination: ProjectView(project)) {
                                ProjectRow(project)
                            }
                        }
                    }
                }
                
                List {
                    Section {
                        MultiColumnView {
                            Button("Logout", action: logout)
                            
                            Text(Strings.logoutFooter)
                                .font(.callout)
                                .foregroundColor(Assets.middleGrey.color)
                        }
                        .withTabBarStyle()
                        
                        MultiColumnView {
                            Button("Delete", action: showDeleteUserAccountAlert)
                                .foregroundColor(.negativeActionButtonColor)
                            
                            Text(Strings.accountDeletionFooter)
                                .foregroundColor(Assets.middleGrey.color)
                                .font(.callout)
                        }
                        .withTabBarStyle()
                    } header: {
                        Text("User")
                    }
                }
                .frame(alignment: .bottom)
            }
            .setTitle("User")
            .alert(isPresented: $showingDeleteUserAccountAlert) {
                return deleteUserAccountAlert()
            }
        default:
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
