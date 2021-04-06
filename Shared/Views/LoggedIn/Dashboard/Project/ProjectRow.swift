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
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top) {
            CircleAround(Image("EdgeImpulse")
                            .resizable())
                .frame(size: .StandardImageSize)

            VStack(alignment: .leading, spacing: 8) {
                Text(project.name)
                    .font(.headline)
                    .bold()
                Text(project.description)
                    .font(.body)
                    .lineLimit(3)
                
                CollaboratorsDisclosureView(project.collaborators)
                
                Text(project.created, style: .date)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
        .padding()
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectRow_Previews: PreviewProvider {
    static var previews: some View {
        ProjectRow(project: .Sample)
            .previewLayout(.sizeThatFits)
    }
}
#endif
