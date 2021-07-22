//
//  Tabs.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/3/21.
//

import SwiftUI

enum Tabs: Int, RawRepresentable, CaseIterable {
    case Devices
    case DataAcquisition
    case Deployment
    case Settings
    
    var keyboardShortcutKey: KeyEquivalent {
        KeyEquivalent(Character("\(rawValue + 1)"))
    }
    
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
        case .Devices:
             DeviceList()
                .frame(minWidth: .minTabWidth)
        case .DataAcquisition:
            DataSamplesView()
                .frame(minWidth: .minTabWidth)
        case .Deployment:
            DeploymentView()
                .frame(minWidth: .minTabWidth)
        case .Settings:
            SettingsContentView()
                .frame(minWidth: .minTabWidth)
        }
    }
}

// MARK: - Identifiable, CustomStringConvertible

extension Tabs: Identifiable, CustomStringConvertible {
    
    var id: Int { rawValue }
    
    var systemImageName: String {
        switch self {
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
