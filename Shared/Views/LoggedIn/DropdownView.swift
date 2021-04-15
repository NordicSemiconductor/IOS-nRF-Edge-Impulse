//
//  DropdownView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 15/4/21.
//

import SwiftUI

struct DropdownView: View {
    
    // MARK: - Private Properties
    
    private let currentProject: Project?
    
    // MARK: - Init
    
    init(currentProject: Project?) {
        self.currentProject = currentProject
    }
    
    // MARK: - body
    
    var body: some View {
        HStack {
            Text(currentProject?.name ?? "Not Available")
            Image(systemName: "chevron.down")
        }
        .font(currentProject != nil ? .headline : .callout)
        .foregroundColor(currentProject != nil ? .white : Assets.lightGrey.color)
    }
}

// MARK: - Preview

#if DEBUG
struct DropdownView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DropdownView(currentProject: nil)
            DropdownView(currentProject: Preview.projectsPreviewAppData.projects.first)
        }
        .background(Assets.blue.color)
        .previewLayout(.sizeThatFits)
    }
}
#endif
