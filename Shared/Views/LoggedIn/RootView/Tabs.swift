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
    
    static let minTabWidth: CGFloat = {
        let value: CGFloat
        #if os(OSX)
        value = 400
        #else
        value = 320
        #endif
        return value
    }()
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .Devices:
             DeviceList()
                .frame(minWidth: Self.minTabWidth)
        case .DataAcquisition:
            DataSamplesView()
                .frame(minWidth: Self.minTabWidth)
        case .Deployment:
            DeploymentView()
                .frame(minWidth: Self.minTabWidth)
        case .Settings:
            SettingsContentView()
                .frame(minWidth: Self.minTabWidth)
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
