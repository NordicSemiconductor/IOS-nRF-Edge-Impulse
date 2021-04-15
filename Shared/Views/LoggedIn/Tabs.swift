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
    case Settings
    
    static var availableCases: [Tabs] {
        #if os(OSX)
        // Preferences is available via Menu on macOS.
        return allCases.filter({ $0 != .Settings })
        #elseif os(iOS)
        return allCases
        #endif
    }
}

// MARK: - ViewBuilder

extension Tabs {
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .Dashboard:
            DashboardView()
        case .Devices:
             DeviceList()
        case .DataAcquisition:
            // Note: There's one for iOS and one for macOS.
            DataAcquisitionView()
        case .Deployment:
            DeploymentView()
        case .Settings:
            SettingsContentView()
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
        case .Settings:
            return "gear"
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
        case .Settings:
            return "Settings"
        }
    }
}
