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
    case DataAcquisition
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
        case .DataAcquisition:
            DataAcquisitionView()
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
        case .DataAcquisition:
            return "cylinder.split.1x2"
        }
    }
    
    var description: String {
        switch self {
        case .Projects:
            return "Projects"
        case .Devices:
            return "Devices"
        case .DataAcquisition:
            return "DataAcquisitionView"
        }
    }
}
