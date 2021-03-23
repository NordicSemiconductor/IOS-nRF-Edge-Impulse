//
//  Tabs.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

enum Tabs: Int, RawRepresentable, CaseIterable {
    case Dashboard
    case Devices
    case DataAcquisition
    case Deployment
}

// MARK: - ViewBuilder

extension Tabs {
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .Dashboard:
            ProjectList()
        case .Devices:
             DeviceList()
        case .DataAcquisition:
            // Note: There's one for iOS and one for macOS.
            DataAcquisitionView()
        case .Deployment:
            DeploymentView()
        }
    }
}

// MARK: - Identifiable, CustomStringConvertible

extension Tabs: Identifiable, CustomStringConvertible {
    
    var id: Int { rawValue }
    
    var systemImageName: String {
        switch self {
        case .Dashboard:
            return "desktopcomputer"
        case .Devices:
            return "cpu"
        case .DataAcquisition:
            return "cylinder.split.1x2"
        case .Deployment:
            return "shippingbox"
        }
    }
    
    var description: String {
        switch self {
        case .Dashboard:
            return "Dashboard"
        case .Devices:
            return "Devices"
        case .DataAcquisition:
            return "Data Acquisition"
        case .Deployment:
            return "Deployment"
        }
    }
}
