//
//  ProjectRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import SwiftUI

// MARK: - ProjectRow

struct ProjectRow: View {
    
    let project: Project
    
    @State private var isShowingListOfCollaborators: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top) {
            CircleAround(Image("EdgeImpulse")
                            .resizable())
                .frame(size: .StandardImageSize)

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                    .bold()
                Text(project.description)
                    .font(.body)
                    .lineLimit(3)
                Text(project.created, style: .date)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .lineLimit(1)
                
                DisclosureGroup(isExpanded: $isShowingListOfCollaborators, content: {
                    ForEach(project.collaborators) { collaborator in
                        HStack {
                            CircleAround(URLImage(url: collaborator.photo, placeholderImage: Image("EdgeImpulse")))
                                .frame(size: .SmallImageSize)
                                .padding(.horizontal, 4)
                            
                            Text(collaborator.username)
                        }
                        .padding(.leading, 4)
                    }
                },
                label: {
                    HStack {
                        Label("Collaborators:", systemImage: "person.fill")
                        
                        if !isShowingListOfCollaborators {
                            ForEach(project.collaborators) { collaborator in
                                CircleAround(URLImage(url: collaborator.photo, placeholderImage: Image("EdgeImpulse")))
                                    .frame(size: .SmallImageSize)
                                    .padding(.horizontal, 2)
                            }
                        }
                    }
                })
                .padding(0)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectRow_Previews: PreviewProvider {
    static var previews: some View {
        ProjectRow(project: .Sample)
            .fixedSize()
    }
}
#endif
