//
//  CollaboratorsDisclosureView.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 6/4/21.
//

import SwiftUI

struct CollaboratorsDisclosureView: View {
    
    private let collaborators: [User]
    
    // MARK: - Init
    
    init(_ collaborators: [User]) {
        self.collaborators = collaborators
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Collaborators:")
                .foregroundColor(.secondary)
                .font(.callout)
                .fontWeight(.bold)
            
            ForEach(collaborators) { collaborator in
                CollaboratorRow(collaborator)
                    .padding(.leading, 3)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CollaboratorsDisclosureView_Previews: PreviewProvider {
    static var previews: some View {
        CollaboratorsDisclosureView(Project.Sample.collaborators)
            .previewLayout(.sizeThatFits)
    }
}
#endif
