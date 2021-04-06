//
//  CollaboratorRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 6/4/21.
//

import SwiftUI

struct CollaboratorRow: View {
    
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
            
            Text(collaborator.username)
                .foregroundColor(.secondary)
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
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
