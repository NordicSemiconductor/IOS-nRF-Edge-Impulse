//
//  CollaboratorRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 6/4/21.
//

import SwiftUI

struct CollaboratorRow: View {
    
    @EnvironmentObject var appData: AppData
    
    private let collaborator: User
    
    // MARK: - Init
    
    init(_ collaborator: User) {
        self.collaborator = collaborator
    }
    
    // MARK: - body
    
    var body: some View {
        HStack {
            CircleAround(URLImage(url: collaborator.photo, placeholderImage: Image("EdgeImpulse")))
                .frame(size: .SmallImageSize)
                .padding(.horizontal, 4)
            
            if let user = appData.user, user == collaborator {
                Text("\(collaborator.name) (You)")
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
            } else {
                Text(collaborator.name)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CollaboratorRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(Project.Sample.collaborators) { collaborator in
                CollaboratorRow(collaborator)
            }
            
            if let user = Preview.projectsPreviewAppData.user {
                CollaboratorRow(user)
            }
        }
        .environmentObject(Preview.projectsPreviewAppData)
        .previewLayout(.sizeThatFits)
    }
}
#endif
