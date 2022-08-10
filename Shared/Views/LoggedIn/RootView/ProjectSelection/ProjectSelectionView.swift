//
//  ProjectSelectionView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 15/4/21.
//

import SwiftUI

struct ProjectSelectionView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    @State private var showingAlert = false
    @State private var preselectedProject: Project?
    
    // MARK: View
    
    var body: some View {
            Menu {
                ForEach(appData.projects ?? []) { project in
                    Button(project.name) {
                        if deviceData.allConnectedOrConnectingDevices().hasItems {
                            preselectedProject = project
                            showingAlert = true
                        } else {
                            appData.selectedProject = project
                        }
                        
                    }
                }
                
                Divider()

                Button(action: logout) {
                    Label("Logout", systemImage: "person.badge.clock")
                }
            } label: {
                DropdownView(currentProject: appData.selectedProject ?? appData.projects?.first)
            }
            .alert(isPresented: $showingAlert, content: {
                Alert(
                    title: Text("Are you sure you want to switch the project?"),
                    message: Text("If you switch the project all connected devices will be disconnected."),
                    primaryButton: .default(Text("Yes"), action: {
                        deviceData.disconnectAll()
                        appData.selectedProject = preselectedProject
                    }),
                    secondaryButton: .cancel(Text("No")))
            })
    }
    
    // MARK: ToolbarItem
    
    func toolbarItem() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            self
                .styleForMacOS()
        }
    }
    
    private func styleForMacOS() -> some View {
        return self
        #if os(OSX)
            .background(Assets.projectSelectorToolbarBackground.color)
            .cornerRadius(8)
        #endif
    }
}

// MARK: - API

fileprivate extension ProjectSelectionView {
    
    func logout() {
        appData.logout()
        deviceData.disconnectAll()
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

struct DropdownToolbarItem_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        Group {
            TabBarLayoutView()
                .preferredColorScheme(.light)
                .environmentObject(Preview.projectsPreviewAppData)
                .environmentObject(Preview.noDevicesAppData)
        }
        #elseif os(OSX)
        Group {
            ThreePaneLayoutView()
                .environmentObject(Preview.projectsPreviewAppData)
//                .environmentObject(Preview.)
        }
        #endif
    }
}
#endif
