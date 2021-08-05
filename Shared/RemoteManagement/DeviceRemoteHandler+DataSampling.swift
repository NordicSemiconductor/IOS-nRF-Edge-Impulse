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
            .tryMap { response -> SamplingState in
                guard response.message.sampleStarted else {
                    throw DeviceRemoteHandler.Error.stringError("Sampling failed to start.")
                }
                return .requestStarted
            }
            .eraseToAnyPublisher()
        
        let uploadingStartedResponse = bluetoothManager.receptionSubject
            .onlyDecode(type: SamplingRequestUploadingResponse.self)
            .tryMap { response -> SamplingState in
                guard response.message.sampleUploading else {
                    throw DeviceRemoteHandler.Error.stringError("Failed to obtain Sample from the Firmware..")
                }
                return .uploading
            }
            .eraseToAnyPublisher()
        
        return Publishers.MergeMany([requestReceptionResponse, samplingStartedResponse, uploadingStartedResponse])
            .eraseToAnyPublisher()
    }
    
    func sendSampleRequestToBLEFirmware(_ request: BLESampleRequestWrapper) throws {
        try bluetoothManager.write(request)
    }
}
