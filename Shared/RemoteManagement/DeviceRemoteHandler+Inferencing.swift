//
//  DeviceRemoteHandler+Inferencing.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 28/9/21.
//

import Foundation
import Combine

// MARK: - InferencingState

extension DeviceRemoteHandler {
    
    enum InferencingState: Equatable {
        case startRequestSent, started
        case stopRequestSent, stopped
    }
}

// MARK: - API

extension DeviceRemoteHandler {
    
    func newStartStopPublisher() -> AnyPublisher<Void, Swift.Error> {
        let startInferencingResponse = bluetoothManager.receptionSubject
            .drop(while: { [unowned self] _ in self.inferencingState != .startRequestSent })
            .onlyDecode(type: InferencingResponse.self)
            .tryMap { [weak self] response in
                if let errorDescription = response.error {
                    throw DeviceRemoteHandler.Error.stringError(errorDescription)
                }
                guard response.ok else {
                    throw DeviceRemoteHandler.Error.stringError("Start Inferencing Returned no Error, but also 'not OK'.")
                }
                guard response.type.contains("start-inferencing") else { return }
                self?.inferencingState = .started
            }
            .eraseToAnyPublisher()
        
        let stopInferencingResponse = bluetoothManager.receptionSubject
            .drop(while: { [unowned self] _ in self.inferencingState != .stopRequestSent })
            .onlyDecode(type: InferencingResponse.self)
            .tryMap { [weak self] response in
                if let errorDescription = response.error {
                    throw DeviceRemoteHandler.Error.stringError(errorDescription)
                }
                guard response.ok else {
                    throw DeviceRemoteHandler.Error.stringError("Start Inferencing Returned no Error, but also 'not OK'.")
                }
                guard response.type.contains("stop-inferencing") else { return }
                self?.inferencingState = .stopped
            }
            .eraseToAnyPublisher()
        
        return Publishers.MergeMany([startInferencingResponse, stopInferencingResponse])
            .eraseToAnyPublisher()
    }
    
    func newResultsPublisher() -> AnyPublisher<InferencingResults, Swift.Error> {
        return bluetoothManager.receptionSubject
            .filter({ [unowned self] _ in self.inferencingState == .started })
//            .gatherData(ofType: InferencingResults.self)
            .onlyDecode(type: InferencingResults.self)
            .tryMap { response -> InferencingResults in
                guard response.type.contains("results") else {
                    throw DeviceRemoteHandler.Error.stringError("")
                }
                return response
            }
            .eraseToAnyPublisher()
    }
}
