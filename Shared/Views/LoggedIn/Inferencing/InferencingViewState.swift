//
//  InferencingViewState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI
import OSLog

final class InferencingViewState: ObservableObject {
    
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: - Properties
    
    @Published var selectedDevice = Constant.unselectedDevice
    @Published var selectedDeviceHandler: DeviceRemoteHandler! {
        didSet {
            guard let selectedDeviceHandler = selectedDeviceHandler else { return }
            selectedDevice = selectedDeviceHandler.device ?? Constant.unselectedDevice
        }
    }
    
    // MARK: - Private Properties
    
    private lazy var logger = Logger(Self.self)
}
