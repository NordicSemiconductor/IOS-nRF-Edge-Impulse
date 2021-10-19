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
    
    // MARK: - Properties
    
    @Published var selectedDevice = Constant.unselectedDevice {
        didSet {
            if selectedDevice == .Unselected {
                onSuddenDisconnection()
            } else {
                buttonEnable = true
            }
        }
    }
    
    @Published var buttonText = "Start"
    @Published var buttonEnable = false
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
    
    func toggleInferencing(with deviceHandler: DeviceRemoteHandler) {
        isInferencing.toggle()
        guard isInferencing else {
            sendStopRequest(with: deviceHandler)
            return
        }
        
        deviceHandler.newStartStopPublisher()
            .sinkReceivingError(onError: { [weak self] error in
                self?.stopAll()
            }, receiveValue: { [weak self] _ in
                switch deviceHandler.inferencingState {
                case .started:
                    self?.results.removeAll()
                case .stopped:
                    self?.stopAll()
                default:
                    break
                }
            })
            .store(in: &cancellables)
        
        deviceHandler.newResultsPublisher()
            .sinkReceivingError(onError: { [weak self] error in
                self?.stopAll()
            }, receiveValue: { [weak self] newResult in
                self?.results.append(newResult)
            })
            .store(in: &cancellables)
        
        sendStartRequest(with: deviceHandler)
    }
    
    func sendStopRequest(with deviceHandler: DeviceRemoteHandler) {
        deviceHandler.inferencingState = .stopRequestSent
        do {
            try deviceHandler.bluetoothManager.write(InferencingRequest(.stop))
        } catch {
            stopAll()
            AppEvents.shared.error = ErrorEvent(error)
        }
    }
}

// MARK: - Private

fileprivate extension InferencingViewState {
    
    func sendStartRequest(with deviceHandler: DeviceRemoteHandler) {
        deviceHandler.inferencingState = .startRequestSent
        do {
            try deviceHandler.bluetoothManager.write(InferencingRequest(.start))
        } catch {
            stopAll()
            AppEvents.shared.error = ErrorEvent(error)
        }
    }
    
    func onSuddenDisconnection() {
        // Don't do
        // selectedDevice = nil
        // or we will end up in an endless loop.
        isInferencing = false
        buttonEnable = false
        stopAll()
    }
    
    func stopAll() {
        if isInferencing {
            isInferencing.toggle()
        }
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }
}
