//
//  RegisteredDevicesData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 01/06/2021.
//

import Combine
import SwiftUI
import os

// MARK: - RegisteredDevicesManager

final class RegisteredDevicesManager {
    private lazy var logger = Logger(Self.self)
    private let network: Network
    
    init(network: Network = .shared) {
        self.network = network
    }
    
    private func requestData(appData: AppData) -> AnyPublisher<(Project, String), Swift.Error> {
        return appData.$selectedProject
            .combineLatest(appData.$apiToken)
            .tryCompactMap { (project, token) -> (Project, String)? in
                guard let t = token else {
                    throw Error.unauthorized
                }
                
                guard let p = project, p.id != 0 else {
                    return nil
                }
                
                return (p, t)
            }
            .eraseToAnyPublisher()
    }
    
    /// Fetch devices from EI and store them into `devices`
    /// - Returns: Publisher with devices from EI. You can subscribe on it to get new results as soos as devices are fetched or just get notified when the request is finished.
    @discardableResult
    func refreshDevices(appData: AppData) -> AnyPublisher<[Device], Swift.Error> {
        requestData(appData: appData)
            .flatMap { (project, token) -> AnyPublisher<GetDeviceListResponse, Swift.Error> in
                guard let request = HTTPRequest.getDevices(for: project, using: token) else {
                    return Fail(error: Error.badRequest).eraseToAnyPublisher()
                }
                
                return self.network.perform(request, responseType: GetDeviceListResponse.self)
            }
            .map(\.devices)
            .justDoIt({ devices in
                self.logger.info("\(devices.count) devices were fetched")
            })
            .eraseToAnyPublisher()
    }
    
    /// Feth the device by `deviceId` and add it to `devices` list.
    /// - Parameter deviceId: Id of the device to fetch
    /// - Returns: Publisher with fetched device. You can subscribe on it to get new result as soos as device is fetched or just get notified when the request is finished.
    @discardableResult
    func fetchDevice(deviceId: String, appData: AppData) -> AnyPublisher<Device, Swift.Error> {
        requestData(appData: appData)
            .flatMap { (project, token) -> AnyPublisher<GetDeviceResponse, Swift.Error> in
                guard let request = HTTPRequest.getDevice(for: project, deviceId: deviceId, using: token) else {
                    return Fail(error: Error.badRequest).eraseToAnyPublisher()
                }
                
                return self.network.perform(request, responseType: GetDeviceResponse.self)
            }
            .map(\.device)
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    func deleteDevice(deviceId: String, appData: AppData) -> AnyPublisher<Void, Swift.Error> {
        return requestData(appData: appData)
            .flatMap { (project, token) -> AnyPublisher<DeleteDeviceResponse, Swift.Error> in
                guard let request = HTTPRequest.deleteDevice(deviceId, from: project, using: token) else {
                    return Fail(error: Error.badRequest).eraseToAnyPublisher()
                }
                
                return self.network.perform(request, responseType: DeleteDeviceResponse.self)
            }
            .eraseToAnyVoidPublisher()
    }
}

// MARK: - Error

extension RegisteredDevicesManager {
    
    enum Error: LocalizedError {
        case unauthorized, badRequest
        case any(Swift.Error)
        
        var failureReason: String? { errorDescription }
        var errorDescription: String? {
            switch self {
            case .unauthorized:
                return "App is not logged-in."
            case .badRequest:
                return "Unable to form HTTP Request."
            case .any(let error):
                return error.localizedDescription
            }
        }
    }
}
