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
    func view(onRetry: @escaping () -> Void) -> some View {
        switch self {
        case .error(let error):
            VStack(alignment: .center, spacing: 8) {
                Text("\(error.localizedDescription)")
                    .multilineTextAlignment(.center)
                Button("Retry", action: onRetry)
                    .circularButtonShape(backgroundAsset: .blue)
            }
        case .empty:
            Text("There are no Projects.")
        case .loading:
            VStack(alignment: .center, spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Loading...")
            }
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
