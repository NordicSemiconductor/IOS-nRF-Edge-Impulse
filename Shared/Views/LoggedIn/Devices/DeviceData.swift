//
//  DeviceData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 15/04/2021.
//

import Foundation
import Combine
import os

class DeviceData: ObservableObject {
    private let logger = Logger(category: "DeviceData")
    let scanner: Scanner
    
    private var deviceHandlers: [UUID: DeviceRemoteHandler] = [:]
    
    @Published var scanResults: [Device] = []
    @Published var connectedDevices: [DeviceRemoteHandler] = []
    
    private var cancelable: Set<AnyCancellable> = []
    
    init(scanner: Scanner = Scanner()) {
        self.scanner = scanner
        
        scanner.devicePublisher
            .removeDuplicates()
            .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
            .sink(receiveCompletion: { result in
                print(result)
            }, receiveValue: {
                self.scanResults.append($0)
                self.logger.info("New Device found: \($0.name), UUID: \($0.id)")
            })
            .store(in: &cancelable)
    }
    
    func deviceHandler(for device: Device) -> DeviceRemoteHandler {
        if let handler = deviceHandlers[device.id] {
            return handler
        } else {
            let handler = DeviceRemoteHandler(device: device)
            deviceHandlers[device.id] = handler
            setupHandlerObservers(handler: handler)
            return handler
        }
    }
    
    private func setupHandlerObservers(handler: DeviceRemoteHandler) {
        handler.$device
            .drop(while: { (device) -> Bool in
                if case .notConnected = device.state {
                    return true
                } else {
                    return false
                }
            })
            .sink { [weak self] (device) in
                guard let `self` = self else { return }
                guard let index = self.scanResults.firstIndex(of: device) else { return }
                self.scanResults[index] = device
            }
            .store(in: &cancelable)
    }
    
}
