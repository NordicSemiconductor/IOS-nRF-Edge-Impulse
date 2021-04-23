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
            if let projects = appData.projects {
                ForEach(projects) { project in
                    Button(project.name) {
                        appData.selectedProject = project
                    }
                }
            } else {
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
                .environmentObject(ScannerData())
        }
        #elseif os(OSX)
        Group {
            ThreePaneLayoutView()
                .environmentObject(Preview.projectsPreviewAppData)
                .environmentObject(ScannerData())
        }
        #endif
    }
}
#endif
