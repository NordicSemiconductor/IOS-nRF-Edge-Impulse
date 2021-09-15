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
                    Label("Logout", systemImage: "person.fill.xmark")
                }
            } label: {
                DropdownView(currentProject: appData.selectedProject ?? appData.projects?.first)
            }
            .alert(isPresented: $showingAlert, content: {
                Alert(
                    title: Text("Are you sure you want to switch the project?"),
                    message: Text("If you switch the project all connected devices will be disconnected"),
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
        #if os(OSX)
        return self
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)
        #else
        return self
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
