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
            #if os(OSX)
            Section(header: Text("Name")) {
                NordicLabel(title: project.name, systemImage: "character.book.closed.fill")
            }
            #endif
            
            Section(header: Text("ID")) {
                NordicLabel(title: String(project.id), systemImage: "key.fill")
            }
            
            Section(header: Text("Description")) {
                NordicLabel(title: project.description, systemImage: "doc.text.fill")
            }
            
            Section(header: Text("Creation Date")) {
                NordicDateLabel(date: project.created, systemImage: "clock.fill")
            }
            
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
