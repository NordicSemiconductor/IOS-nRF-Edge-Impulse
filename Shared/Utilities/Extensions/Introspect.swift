//
//  Introspect.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 13/7/21.
//

import Foundation

#if canImport(UIKit)
import UIKit

extension UITableView {
    
    func scrollToBottom() {
        guard let dataSource = dataSource, let numberOfSections = dataSource.numberOfSections?(in: self),
              numberOfSections > 0 else { return }
        let numberOfRows = dataSource.tableView(self, numberOfRowsInSection: numberOfSections - 1)
        guard numberOfRows > 0 else { return }
        let indexPath = IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
        scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}

#endif

#if canImport(AppKit)
import AppKit

extension NSTableView {
    
    func scrollToBottom() {
        guard numberOfRows > 0 else { return }
        scrollRowToVisible(numberOfRows - 1)
    }
}

#endif
