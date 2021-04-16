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
            CircleAround(URLImage(url: collaborator.photo, placeholderImage: Image("EdgeImpulse")))
                .frame(size: .SmallImageSize)
                .padding(.horizontal, 4)
            
            switch appData.viewState {
            case .showingUser(let user, _):
                if user == collaborator {
                    Text("\(collaborator.username) (You)")
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                } else {
                    Text(collaborator.username)
                        .foregroundColor(.secondary)
                }
            default:
                EmptyView()
            }
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
            switch Preview.projectsPreviewAppData.viewState {
            case .showingUser(let user, _):
                CollaboratorRow(user)
            default:
                EmptyView()
            }
        }
        .environmentObject(Preview.projectsPreviewAppData)
        .previewLayout(.sizeThatFits)
    }
}
#endif
