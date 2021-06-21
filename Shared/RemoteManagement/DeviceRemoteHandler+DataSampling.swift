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
        guard let btPublisher = btPublisher else { return nil }
        
        
        
        let requestReceptionResponse = btPublisher
            .onlyDecode(type: SamplingRequestReceivedResponse.self)
            .first()
            .tryMap { [bluetoothManager] response -> SamplingState in
                guard response.sample else {
                    throw DeviceRemoteHandler.Error.stringError("Returned Not Successful.")
                }
                #if DEBUG
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    bluetoothManager?.mockFirmwareResponse(SamplingRequestStartedResponse(sampleStarted: true))
                }
                #endif
                return .requestReceived
            }
            .eraseToAnyPublisher()
        
        let samplingStartedResponse = btPublisher
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
                requestReceptionResponse, samplingStartedResponse
            ])
            .eraseToAnyPublisher()
    }
    
    func sendSampleRequestToBLEFirmware(_ request: BLESampleRequestWrapper) throws {
        try bluetoothManager.write(request)
        #warning("test code")
        #if DEBUG
        bluetoothManager.mockFirmwareResponse(SamplingRequestReceivedResponse(sample: true))
        #endif
    }
}
