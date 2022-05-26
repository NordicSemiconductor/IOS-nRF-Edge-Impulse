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
            List {
                HeroView(user: user)
                    .listRowInsets(EdgeInsets())
                
                Divider()
                
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
                
                Section(content: {
                    HStack {
                        VStack {
                            Image(systemName: "person.badge.clock")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30, alignment: .center)
                            
                            Button("Logout", action: logout)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        Divider()
                            .foregroundColor(Assets.lightGrey.color)
                        
                        VStack {
                            Image(systemName: "person.badge.minus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30, alignment: .center)
                            
                            Button("Delete", action: showDeleteUserAccountAlert)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .foregroundColor(.negativeActionButtonColor)
                    }
                    .padding(4)
                    .withTabBarStyle()
                }, header: {
                    Text("Account")
                }, footer: {
                    Text(Strings.accountDeletionFooter)
                        .font(.body)
                        .foregroundColor(Assets.middleGrey.color)
                })
            }
            .setTitle("User")
            .alert(isPresented: $showingDeleteUserAccountAlert) {
                Alert(title: Text(Strings.deleteUserAccount),
                      message: Text(Strings.deleteUserAccountDescription),
                      primaryButton: .destructive(Text("Yes"), action: confirmDeleteUserAccount),
                      secondaryButton: .default(Text("Cancel"), action: dismissDeleteUserAccount))
            }
        default:
            EmptyView()
        }
    }
}

struct UserContentView_Previews: PreviewProvider {
    static var previews: some View {
        UserContentView()
    }
}
