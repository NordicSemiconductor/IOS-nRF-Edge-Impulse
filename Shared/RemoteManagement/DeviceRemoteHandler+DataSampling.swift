//
//  DeviceRemoteHandler+DataSampling.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 16/6/21.
//

import Foundation
import Combine

extension DeviceRemoteHandler {
    
    func samplingRequestPublisher() -> AnyPublisher<SamplingState, Swift.Error>? {        
        let requestReceptionResponse = bluetoothManager.receptionSubject
            .onlyDecode(type: SamplingRequestReceivedResponse.self)
            .tryMap { response -> SamplingState in
                guard response.message.sample else {
                    throw DeviceRemoteHandler.Error.stringError("Returned Not Successful.")
                }
                return .requestReceived
            }
            .eraseToAnyPublisher()
        
        let samplingStartedResponse = bluetoothManager.receptionSubject
            .onlyDecode(type: SamplingRequestStartedResponse.self)
            .first()
            .tryMap { response -> SamplingState in
                guard response.sampleStarted else {
                    throw DeviceRemoteHandler.Error.stringError("Sampling failed to start.")
                }
                return .requestStarted
            }
            .eraseToAnyPublisher()
        
        return Publishers.MergeMany([
                requestReceptionResponse
            ])
            .eraseToAnyPublisher()
    }
    
    func sendSampleRequestToBLEFirmware(_ request: BLESampleRequestWrapper) throws {
        try bluetoothManager.write(request)
    }
}
