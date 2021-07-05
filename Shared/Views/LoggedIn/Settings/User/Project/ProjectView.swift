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
        List {
            #if os(OSX)
            Section(header: Text("Name")) {
                Label(project.name, systemImage: "character.book.closed.fill")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            #endif
            
            Section(header: Text("ID")) {
                Label(String(project.id), systemImage: "key.fill")
                    .foregroundColor(.primary)
            }
            
            Section(header: Text("Description")) {
                Label(project.description, systemImage: "doc.text.fill")
                    .foregroundColor(.primary)
            }
            
            Section(header: Text("Creation Date")) {
                Label(
                    title: { Text(project.created, style: .date) },
                    icon: {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.primary)
                    }
                )
            }
            
            Section(header: Text("Collaborators")) {
                ForEach(project.collaborators) { collaborator in
                    CollaboratorRow(collaborator)
                }
            }
        }
        .setTitle(project.name)
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
