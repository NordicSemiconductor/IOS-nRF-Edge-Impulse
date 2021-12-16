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
            #if os(OSX)
            Image(systemName: currentProject != nil ? "network" : "bolt.horizontal.fill")
            #endif
            Text(currentProject?.name ?? "Not Available")
            #if os(iOS)
            Image(systemName: "chevron.down")
            #endif
        }
        .font(currentProject != nil ? .headline : .callout)
    }
}

// MARK: - Preview

#if DEBUG
struct DropdownView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DropdownView(currentProject: nil)
            DropdownView(currentProject: Preview.previewProjects.first)
        }
        .background(Assets.blue.color)
        .previewLayout(.sizeThatFits)
    }
}
#endif
