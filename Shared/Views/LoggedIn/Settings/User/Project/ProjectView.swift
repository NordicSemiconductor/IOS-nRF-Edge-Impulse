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
        Text("Hello, World!")
            .setTitle(project.name)
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView(.Unselected)
            .previewLayout(.sizeThatFits)
    }
}
#endif
