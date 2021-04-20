//
//  UserView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI
import Combine

struct UserView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - View
    
    var body: some View {
        VStack {
            switch appData.loginState {
            case .complete(let user, let projects):
                List {
                    HeroView(user: user)
                    
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
                }
            default:
                EmptyView()
            }
        }
        .frame(minWidth: 295)
    }
}



// MARK: - Preview

#if DEBUG
struct UserView_Previews: PreviewProvider {
    
    static let loggedInWithoutUser: AppData = {
        let appData = AppData()
        appData.apiToken = "A"
        appData.loginState = .empty
        return appData
    }()
    
    static var previews: some View {
        Group {
            UserView()
                .environmentObject(Preview.noProjectsAppData)
            UserView()
                .environmentObject(Preview.projectsPreviewAppData)
        }
    }
}
#endif
