//
//  Tabs.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

enum Tabs: Int, RawRepresentable, CaseIterable {
    case Projects
    case Devices
}

// MARK: - ViewBuilder

extension Tabs {
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .Projects:
            ProjectList()
        case .Devices:
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
        case .Devices:
            return "apps.ipad"
        }
    }
    
    var description: String {
        switch self {
        case .Projects:
            return "Projects"
        case .Devices:
            return "Devices"
        }
    }
}
