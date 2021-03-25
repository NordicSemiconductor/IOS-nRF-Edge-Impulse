//
//  DashboardView+ViewState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/3/21.
//

import SwiftUI

// MARK: - DashboardView.Status

extension DashboardView {
    
    enum ViewState {
        case error(_ error: Error)
        case empty
        case loading
        case showingUser(_ user: User, _ projects: [Project])
    }
}

// MARK: - ViewBuilder

extension DashboardView.ViewState {
 
    @ViewBuilder
    func view(onRetry: @escaping () -> Void) -> some View {
        switch self {
        case .error(let error):
            VStack(alignment: .center, spacing: 8) {
                ErrorView(error: error)
                Button("Retry", action: onRetry)
                    .circularButtonShape(backgroundAsset: .blue)
            }
        case .empty:
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "moon.stars.fill")
                    .resizable()
                    .frame(width: 90, height: 90, alignment: .center)
                    .foregroundColor(Assets.blueslate.color)
                Text("Your Project List is empty.")
            }
        case .loading:
            VStack(alignment: .center, spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Loading...")
            }
        case .showingUser(let user, let projects):
            VStack {
                UserView(user: user)
                    
                List {
                    Section(header: Text("Projects")) {
                        ForEach(projects) { project in
                            ProjectRow(project: project)
                        }
                    }
                }
            }
            .frame(minWidth: 295)
        }
    }
}

// MARK: - CaseIterable

extension DashboardView.ViewState: CaseIterable {
    static var allCases: [DashboardView.ViewState] = [
        .error(NordicError(description: "Sample Error")),
        .empty,
        .loading,
        .showingUser(ProjectList_Previews.previewUser, ProjectList_Previews.previewProjects)
    ]
}
