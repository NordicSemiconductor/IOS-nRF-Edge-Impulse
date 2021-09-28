//
//  InferencingViewState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 27/9/21.
//

import SwiftUI
import Combine
import OSLog

// MARK: - InferencingViewState

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
    
    @Published var buttonText = "Start"
    @Published var isInferencing = false {
        didSet {
            buttonText = isInferencing ? "Stop" : "Start"
        }
    }
    
    // MARK: - Private Properties
    
    private lazy var logger = Logger(Self.self)
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - API

extension InferencingViewState {
    
    func toggleInferencing() {
        isInferencing.toggle()
    }
}
