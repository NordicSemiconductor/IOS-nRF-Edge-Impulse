//
//  RegisteredDevicesData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 01/06/2021.
//

import Combine
import SwiftUI

class RegisteredDevicesManager {
    
    private let network: Network
    
    init(network: Network = .shared) {
        self.network = network
    }
    
    enum Error: Swift.Error {
        case unauthorized, badRequest
        case any(Swift.Error)
    }
    
    private func requestData(appData: AppData) -> AnyPublisher<(Project, String), Swift.Error> {
        return appData.$selectedProject
            .combineLatest(appData.$apiToken)
            .tryCompactMap { (project, token) -> (Project, String)? in
                guard let t = token else {
                    throw Error.unauthorized
                }
                
                guard let p = project else {
                    return nil
                }
                
                return (p, t)
            }
            .eraseToAnyPublisher()
    }
    
    /// Fetch devices from EI and store them into `devices`
    /// - Returns: Publisher with devices from EI. You can subscribe on it to get new results as soos as devices are fetched or just get notified when the request is finished.
    @discardableResult
    func refreshDevices(appData: AppData) -> AnyPublisher<[RegisteredDevice], Swift.Error> {
        return requestData(appData: appData)
            .flatMap { (project, token) -> AnyPublisher<[RegisteredDevice], Swift.Error> in
                guard let request = HTTPRequest.getDevices(for: project, using: token) else {
                    return Fail(error: Error.badRequest).eraseToAnyPublisher()
                }
                
                return self.network.perform(request, responseType: [RegisteredDevice].self)
            }
            .eraseToAnyPublisher()
    }
    
    /// Feth the device by `deviceId` and add it to `devices` list.
    /// - Parameter deviceId: Id of the device to fetch
    /// - Returns: Publisher with fetched device. You can subscribe on it to get new result as soos as device is fetched or just get notified when the request is finished.
    @discardableResult
    func fetchDevice(deviceId: String, appData: AppData) -> AnyPublisher<RegisteredDevice, Swift.Error> {
        return requestData(appData: appData)
            .flatMap { (project, token) -> AnyPublisher<RegisteredDevice, Swift.Error> in
                guard let request = HTTPRequest.getDevice(for: project, deviceId: deviceId, using: token) else {
                    return Fail(error: Error.badRequest).eraseToAnyPublisher()
                }
                
                return self.network.perform(request, responseType: RegisteredDevice.self)
            }
            .eraseToAnyPublisher()
    }
}
