//
//  UserContentView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 22/4/21.
//

import SwiftUI

struct UserContentView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - View
    
    var body: some View {
        switch appData.loginState {
        case .complete(let user, let projects):
            List {
                HeroView(user: user)
                    .listRowInsets(EdgeInsets())
                
                Section(header: Text("Projects")) {
                    if projects.isEmpty {
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "moon.stars.fill")
                                .resizable()
                                .frame(width: 90, height: 90, alignment: .center)
                                .foregroundColor(Assets.blueslate.color)
                            Text("Your Project List is empty.")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    ForEach(projects) { project in
                        ProjectRow(project)
                    }
                }
                
                Section(header: Text("Account")) {
                    Button("Logout", action: appData.logout)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Assets.red.color)
                }
            }
            .setTitle("User")
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct UserContentView_Previews: PreviewProvider {
    
    static let loggedInWithoutUser: AppData = {
        let appData = AppData()
        appData.apiToken = "A"
        appData.loginState = .empty
        return appData
    }()
    
    static var previews: some View {
        Group {
            UserContentView()
                .environmentObject(Preview.noProjectsAppData)
            UserContentView()
                .environmentObject(Preview.projectsPreviewAppData)
        }
    }
}
#endif
