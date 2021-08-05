//
//  DeviceRemoteHandler+DataSampling.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 16/6/21.
//

import Foundation
import Combine

extension DeviceRemoteHandler {
    
    func samplingRequestPublisher() -> AnyPublisher<Void, Swift.Error>? {
        let requestReceptionResponse = bluetoothManager.receptionSubject
            .onlyDecode(type: SamplingRequestReceivedResponse.self)
            .tryMap { [weak self] response in
                guard response.message.sample else {
                    throw DeviceRemoteHandler.Error.stringError("Returned Not Successful")
                }
                self?.samplingState = .requestStarted
            }
            .eraseToAnyPublisher()
        
        let samplingStartedResponse = bluetoothManager.receptionSubject
            .drop(while: { [unowned self] _ in self.samplingState != .requestReceived })
            .onlyDecode(type: SamplingRequestStartedResponse.self)
            .tryMap { [weak self] response in
                guard response.message.sampleStarted else {
                    throw DeviceRemoteHandler.Error.stringError("Sampling failed to start")
                }
                self?.samplingState = .requestStarted
            }
            .eraseToAnyPublisher()
        
        let uploadingStartedResponse = bluetoothManager.receptionSubject
            .drop(while: { [unowned self] _ in self.samplingState != .requestStarted })
            .onlyDecode(type: SamplingRequestUploadingResponse.self)
            .tryMap { [weak self] response in
                guard response.message.sampleUploading else {
                    throw DeviceRemoteHandler.Error.stringError("Failed to obtain Sample from the Firmware")
                }
                self?.samplingState = .receivingFromFirmware
            }
            .eraseToAnyPublisher()
        
        let samplingResultResponse = bluetoothManager.receptionSubject
            .drop(while: { [unowned self] _ in self.samplingState != .receivingFromFirmware })
            .gatherData(ofType: SamplingRequestFinishedResponse.self)
            .tryMap { [weak self] response in
                guard response.type == "http" else { //let binary = Data(base64Encoded: response.body) else {
                    throw DeviceRemoteHandler.Error.stringError("Failed to obtain Sample from the Firmware")
                }
                self?.samplingState = .completed
            }
            .eraseToAnyPublisher()
        
        return Publishers.MergeMany([requestReceptionResponse, samplingStartedResponse,
                                     uploadingStartedResponse, samplingResultResponse])
            .eraseToAnyPublisher()
    }
    
    func sendSampleRequestToBLEFirmware(_ request: BLESampleRequestWrapper) throws {
        try bluetoothManager.write(request)
    }
}
