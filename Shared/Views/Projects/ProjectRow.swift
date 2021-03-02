//
//  ProjectRow.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/3/21.
//

import SwiftUI

// MARK: - ProjectRow

struct ProjectRow: View {
    var project: Project
    
    var body: some View {
        HStack {
            Image("nRFConnect")
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(12)
            VStack(alignment: .leading) {
                Text(project.name)
                    .font(.headline)
                    .bold()
                Text(project.description)
                    .font(.caption)
                    .lineLimit(1)
                Text(project.created, style: .date)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
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
