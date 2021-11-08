//
//  ProjectView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/5/21.
//

import SwiftUI

struct ProjectView: View {
    
    // MARK: - Private Properties
    
    private let project: Project
    
    // MARK: Init
    
    init(_ project: Project) {
        self.project = project
    }
    
    // MARK: View
    
    var body: some View {
        FormIniOSListInMacOS {
            Section(header: Text("Project Information")) {
                StringDeviceInfoRow(title: "ID", systemImage: "key.fill", content: String(project.id))
                
                #if os(macOS)
                StringDeviceInfoRow(title: "Name", systemImage: "character.book.closed.fill", content: project.name)
                #endif
                
                DateDeviceInfoRow(title: "Creation Date", systemImage: "clock.fill", content: project.created)
            }
            
            #if os(macOS)
            Divider()
            #endif
            
            Section(header: Text("Description")) {
                NordicLabel(title: project.description, systemImage: "doc.text.fill")
            }
            
            #if os(macOS)
            Divider()
            #endif
            
            Section(header: Text("Collaborators")) {
                ForEach(project.collaborators) { collaborator in
                    CollaboratorRow(collaborator)
                }
            }
        }
        .setTitle(project.name)
        .accentColor(.primary)
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView(Project.Sample)
            .environmentObject(Preview.projectsPreviewAppData)
            .previewLayout(.sizeThatFits)
    }
}
#endif
