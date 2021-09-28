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
    @Published var results = [InferencingResults]()
    
    // MARK: - Private Properties
    
    private lazy var logger = Logger(Self.self)
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - API

extension InferencingViewState {
    
    func toggleInferencing() {
        isInferencing.toggle()
        guard isInferencing else {
            sendStopRequest()
            return
        }
        
        selectedDeviceHandler.newStartStopPublisher()
            .sinkReceivingError(onError: { [weak self] error in
                self?.stopAll()
            }, receiveValue: { [weak self] _ in
                switch self?.selectedDeviceHandler.inferencingState {
                case .started:
                    self?.results.removeAll()
                case .stopped:
                    self?.stopAll()
                default:
                    break
                }
            })
            .store(in: &cancellables)
        
        selectedDeviceHandler.newResultsPublisher()
            .sinkReceivingError(onError: { [weak self] error in
                self?.stopAll()
            }, receiveValue: { [weak self] newResult in
                self?.results.append(newResult)
            })
            .store(in: &cancellables)
        
        sendStartRequest()
    }
}

// MARK: - Private

fileprivate extension InferencingViewState {
    
    func sendStartRequest() {
        selectedDeviceHandler.inferencingState = .startRequestSent
        do {
            try selectedDeviceHandler.bluetoothManager.write(InferencingRequest(.start))
        } catch {
            stopAll()
            AppEvents.shared.error = ErrorEvent(error)
        }
    }
    
    func sendStopRequest() {
        selectedDeviceHandler.inferencingState = .stopRequestSent
        do {
            try selectedDeviceHandler.bluetoothManager.write(InferencingRequest(.stop))
        } catch {
            stopAll()
            AppEvents.shared.error = ErrorEvent(error)
        }
    }
    
    func stopAll() {
        if isInferencing {
            isInferencing.toggle()
        }
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }
}
