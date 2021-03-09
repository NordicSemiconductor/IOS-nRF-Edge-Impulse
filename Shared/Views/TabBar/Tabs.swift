//
//  Tabs.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

enum Tabs: Int, RawRepresentable, CaseIterable {
    case Projects
    case Scanner
}

// MARK: - ViewBuilder

extension Tabs {
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .Projects:
            ProjectList()
        case .Scanner:
             DeviceList()
        }
    }
}

// MARK: - Identifiable, CustomStringConvertible

extension Tabs: Identifiable, CustomStringConvertible {
    
    var id: Int { rawValue }
    
    var systemImageName: String {
        switch self {
        case .Projects:
            return "list.bullet"
        case .Scanner:
            return "wave.3.left"
        }
    }
    
    var description: String {
        switch self {
        case .Projects:
            return "Projects"
        case .Scanner:
            return "Scanner"
        }
    }
}
