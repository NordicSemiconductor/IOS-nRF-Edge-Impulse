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
            #if os(OSX)
            CircleAround(URLImage(url: collaborator.photo, placeholderImage: Image("EdgeImpulse")))
                .frame(size: .SmallImageSize)
            #else
            CircleAround(URLImage(url: collaborator.photo, placeholderImage: Image("EdgeImpulse")))
                .frame(size: .SmallImageSize)
                .padding(.horizontal, 6)
            #endif
            
            if let user = appData.user, user == collaborator {
                Text("\(collaborator.formattedName) (You)")
                    .foregroundColor(.secondary)
                    .fontWeight(.bold)
            } else {
                Text(collaborator.formattedName)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
import iOS_Common_Libraries

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
