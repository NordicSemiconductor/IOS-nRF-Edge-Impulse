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
    
    // MARK: - @viewBuilder
    
    var body: some View {
        VStack {
            switch appData.loginState {
            case .showingUser(let user, let projects):
                HeroView(user: user)
                    
                List {
                    Section(header: Text("Projects")) {
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
                .environmentObject(Preview.previewAppData(.loading))
            UserView()
                .environmentObject(Preview.projectsPreviewAppData)
        }
    }
}
#endif
