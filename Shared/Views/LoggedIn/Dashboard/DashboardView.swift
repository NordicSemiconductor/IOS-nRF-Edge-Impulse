//
//  DashboardView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI
import Combine

struct DashboardView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - @viewBuilder
    
    var body: some View {
        VStack {
            switch appData.loginState {
            case .showingUser(let user, let projects):
                UserView(user: user)
                    
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
struct DashboardView_Previews: PreviewProvider {
    
    static let loggedInWithoutUser: AppData = {
        let appData = AppData()
        appData.apiToken = "A"
        appData.loginState = .empty
        return appData
    }()
    
    static var previews: some View {
        Group {
            DashboardView()
                .environmentObject(Preview.previewAppData(.loading))
            DashboardView()
                .environmentObject(Preview.projectsPreviewAppData)
        }
    }
}
#endif
