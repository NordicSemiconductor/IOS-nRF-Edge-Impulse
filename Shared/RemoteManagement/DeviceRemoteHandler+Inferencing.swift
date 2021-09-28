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
    
    enum InferencingState {
        case startRequestSent, started
        case stopRequestSent, stopped
    }
}

// MARK: - API

extension DeviceRemoteHandler {
    
    func newInferencingPublisher() -> AnyPublisher<InferencingState?, Swift.Error> {
        let startInferencingResponse = bluetoothManager.receptionSubject
            .drop(while: { [unowned self] _ in self.inferencingState != .startRequestSent })
            .onlyDecode(type: InferencingResponse.self)
            .tryMap { response -> InferencingState? in
                if let errorDescription = response.error {
                    throw DeviceRemoteHandler.Error.stringError(errorDescription)
                }
                guard response.ok else {
                    throw DeviceRemoteHandler.Error.stringError("Start Inferencing Returned no Error, but also 'not OK'.")
                }
                guard response.type == "start-inferencing" else { return nil }
                return .started
            }
            .eraseToAnyPublisher()
        
        let inferencingResultsResponse = bluetoothManager.receptionSubject
            .drop(while: { [unowned self] _ in self.inferencingState != .started })
            .onlyDecode(type: InferencingResults.self)
            .tryMap { [weak self] response -> InferencingState? in
                guard response.type == "inference-results" else { return nil }
                return .started
            }
            .eraseToAnyPublisher()
        
        let stopInferencingResponse = bluetoothManager.receptionSubject
            .drop(while: { [unowned self] _ in self.inferencingState != .started })
            .onlyDecode(type: InferencingResponse.self)
            .tryMap { response -> InferencingState? in
                if let errorDescription = response.error {
                    throw DeviceRemoteHandler.Error.stringError(errorDescription)
                }
                guard response.ok else {
                    throw DeviceRemoteHandler.Error.stringError("Start Inferencing Returned no Error, but also 'not OK'.")
                }
                guard response.type == "stop-inferencing" else { return nil }
                return .stopped
            }
            .eraseToAnyPublisher()
        
        return Publishers.MergeMany([startInferencingResponse, inferencingResultsResponse, stopInferencingResponse])
            .eraseToAnyPublisher()
    }
}
