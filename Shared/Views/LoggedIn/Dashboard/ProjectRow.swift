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
    
    var body: some View {
        HStack(alignment: .top) {
            CircleAround(Image("EdgeImpulse")
                            .resizable())
                .frame(width: 40, height: 40)

            VStack(alignment: .leading) {
                Text(project.name)
                    .font(.headline)
                    .bold()
                Text(project.description)
                    .font(.body)
                    .lineLimit(1)
                Text(project.created, style: .date)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Preview

#if DEBUG
struct ProjectRow_Previews: PreviewProvider {
    static var previews: some View {
        ProjectRow(project: .Sample)
    }
}
#endif
