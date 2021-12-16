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
    case Inferencing
    case Settings
    case User
    
    var keyboardShortcutKey: KeyEquivalent {
        KeyEquivalent(Character("\(rawValue + 1)"))
    }
    
    static var availableCases: [Tabs] {
        #if os(OSX)
        // Preferences is available via Menu on macOS.
        return allCases.filter { $0 != .Settings }.filter { $0 != .User }
        #elseif os(iOS)
        return allCases.filter { $0 != User }
        #endif
    }
}

// MARK: - ViewBuilder

extension Tabs {
    
    @ViewBuilder
    func view(with appData: AppData) -> some View {
        switch self {
        case .Devices:
             DeviceList()
                .frame(minWidth: .minTabWidth)
        case .DataAcquisition:
            DataSamplesView()
                .frame(minWidth: .minTabWidth)
        case .Deployment:
            DeploymentView()
                .environmentObject(appData.deploymentViewState)
                .frame(minWidth: .minTabWidth)
        case .Inferencing:
            InferencingView()
                .frame(minWidth: .minTabWidth)
        case .Settings:
            SettingsContentView()
                .frame(minWidth: .minTabWidth)
        case .User:
            UserContentView()
                .frame(width: .minTabWidth)
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
        case .Inferencing:
            return "chart.bar.doc.horizontal"
        case .Settings:
            return "gear"
        case .User:
            return "person.fill"
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
        case .Inferencing:
            return "Inferencing"
        case .Settings:
            return "Settings"
        case .User:
            return "User"
        }
    }
}
