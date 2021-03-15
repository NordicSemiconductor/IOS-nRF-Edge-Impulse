//
//  ProjectList+Status.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/3/21.
//

import SwiftUI

// MARK: - ProjectList.Status

extension ProjectList {
    
    enum Status {
        case error(_ error: Error)
        case empty
        case loading
        case showingProjects(_ projects: [Project])
    }
}

// MARK: - ViewBuilder

extension ProjectList.Status {
 
    @ViewBuilder
    var view: some View {
        switch self {
        case .error(let error):
            Text("\(error.localizedDescription)")
                .multilineTextAlignment(.center)
        case .empty:
            Text("There are no Projects.")
        case .loading:
            Text("Loading...")
        case .showingProjects(let projects):
            List {
                ForEach(projects) { project in
                    NavigationLink(destination: DataAcquisitionView(project: project)) {
                        ProjectRow(project: project)
                    }
                }
            }
        }
    }
}

// MARK: - CaseIterable

extension ProjectList.Status: CaseIterable {
    static var allCases: [ProjectList.Status] = [
        .error(NordicError(description: "Sample Error")),
        .empty,
        .loading,
        .showingProjects(ProjectList_Previews.previewProjects)
    ]
}
