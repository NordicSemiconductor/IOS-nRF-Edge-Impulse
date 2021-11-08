//
//  ProjectRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import SwiftUI

// MARK: - ProjectRow

struct ProjectRow: View {
    
    private let project: Project
    
    // MARK: - Init
    
    init(_ project: Project) {
        self.project = project
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center) {
            CircleAround(URLImage(url: project.logo, placeholderImage: Image("EdgeImpulse")))
                .frame(size: .ToolbarImageSize)

            Text(project.name)
                .font(.headline)
                .bold()
            
            CollaboratorsHStackView(project.collaborators)
        }
        .frame(height: CGSize.ToolbarImageSize.height + CGSize.TableViewPaddingSize.height)
        .padding(.horizontal, 6)
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectRow_Previews: PreviewProvider {
    static var previews: some View {
        ProjectRow(.Sample)
            .previewLayout(.sizeThatFits)
    }
}
#endif
