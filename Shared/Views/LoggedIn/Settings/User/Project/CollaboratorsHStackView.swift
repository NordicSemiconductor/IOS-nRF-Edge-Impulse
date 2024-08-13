//
//  CollaboratorsHStackView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/5/21.
//

import SwiftUI

// MARK: - CollaboratorsHStackView

struct CollaboratorsHStackView: View {
    
    private let collaborators: [User]
    
    // MARK: Init
    
    init(_ collaborators: [User]) {
        self.collaborators = collaborators
    }
    
    // MARK: View
    
    var body: some View {
        ZStack {
            ForEach(0..<collaborators.count, id: \.self) { i in
                ZStack(alignment: .leading) {
                    CircleAround(URLImage(url: collaborators[i].photo, placeholderImage: Image("EdgeImpulse")))
                        .frame(size: .SmallImageSize)
                }
                .offset(x: CGFloat(i) * 12)
            }
        }
        .padding(.trailing, CGFloat(collaborators.count) * 9)
    }
}

// MARK: - Preview

#if DEBUG
struct CollaboratorsHStackView_Previews: PreviewProvider {
    
    static var previews: some View {
        CollaboratorsHStackView(Project.Unselected!.collaborators)
            .previewLayout(.sizeThatFits)
    }
}
#endif
