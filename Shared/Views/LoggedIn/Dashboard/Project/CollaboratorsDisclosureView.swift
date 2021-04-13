//
//  CollaboratorsDisclosureView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 6/4/21.
//

import SwiftUI

struct CollaboratorsDisclosureView: View {
    
    private let collaborators: [User]
    @State private var isShowingListOfCollaborators: Bool = false
    
    // MARK: - Init
    
    init(_ collaborators: [User]) {
        self.collaborators = collaborators
    }
    
    // MARK: - Body
    
    var body: some View {
        DisclosureGroup(isExpanded: $isShowingListOfCollaborators, content: {
            VStack(alignment: .leading) {
                ForEach(collaborators) { collaborator in
                    CollaboratorRow(collaborator)
                        .padding(.leading, 3)
                }
            }
        },
        label: {
            HStack {
                Label(title: {
                    Text("Collaborators")
                        .fontWeight(.bold)
                        .font(.callout)
                    },
                    icon: {
                        Image(systemName: "person.fill")
                    }
                )
                
                if !isShowingListOfCollaborators {
                    ForEach(collaborators) { collaborator in
                        CircleAround(URLImage(url: collaborator.photo, placeholderImage: Image("EdgeImpulse")))
                            .frame(size: .SmallImageSize)
                            .padding(.leading, 4)
                    }
                }
            }
        })
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
