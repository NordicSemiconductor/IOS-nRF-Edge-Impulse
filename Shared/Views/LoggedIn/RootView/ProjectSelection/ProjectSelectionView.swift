//
//  ProjectSelectionView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 15/4/21.
//

import SwiftUI

struct ProjectSelectionView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: View
    
    var body: some View {
        Menu {
            switch appData.loginState {
            case .showingUser(_, let projects):
                ForEach(projects) { project in
                    Button(action: {
                        appData.selectedProject = project
                    }) {
                        Label(project.name, systemImage: "pencil")
                    }
                }
            default:
                EmptyView()
            }
            
            Divider()

            Button(action: logout) {
                Label("Logout", systemImage: "person.fill.xmark")
            }
        } label: {
            DropdownView(currentProject: appData.selectedProject ?? appData.projects?.first)
        }
    }
    
    // MARK: ToolbarItem
    
    func toolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            self
        }
    }
}

// MARK: - API

fileprivate extension ProjectSelectionView {
    
    func logout() {
        appData.logout()
    }
}

// MARK: - Preview

#if DEBUG
struct DropdownToolbarItem_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        Group {
            TabBarLayoutView()
                .preferredColorScheme(.light)
                .environmentObject(Preview.projectsPreviewAppData)
        }
        #elseif os(OSX)
        Group {
            ThreePaneLayoutView()
                .environmentObject(Preview.projectsPreviewAppData)
        }
        #endif
    }
}
#endif
