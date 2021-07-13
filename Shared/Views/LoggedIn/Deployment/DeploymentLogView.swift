//
//  DeploymentLogView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 12/7/21.
//

import SwiftUI

struct DeploymentLogView: View {
    
    @EnvironmentObject var viewState: DeploymentViewState
    
    var body: some View {
        Form {
            ForEach(viewState.logMessages, id: \.self) { message in
                Text(message)
            }
        }
        .introspectTableView { tableView in
            viewState.logMessages.publisher
                .debounce(for: 300, scheduler: DispatchQueue.main)
                .collect()
                .sink { [weak tableView] _ in
                    guard let tableView = tableView, let dataSource = tableView.dataSource,
                          let sections = dataSource.numberOfSections?(in: tableView),
                          sections > 0 else { return }
                    let numberOfRows = dataSource.tableView(tableView, numberOfRowsInSection: 0)
                    guard numberOfRows > 0 else { return }
                    let indexPath = IndexPath(row: numberOfRows - 1, section: 0)
                    tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
                .store(in: &viewState.cancellables)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeploymentLogView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeploymentLogView()
                .environmentObject(DeploymentViewState())
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
