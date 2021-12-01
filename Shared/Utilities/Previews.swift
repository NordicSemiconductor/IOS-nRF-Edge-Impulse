//
//  Previews.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/3/21.
//

import Foundation

#if DEBUG
struct Preview {
    
    // MARK: - AppData
    
    static var previewUser = User(id: 3, username: "independence.day", name: "ID4", created: Date())
    
    static var previewProjects: [Project]! = {
        return try? decode(filename: "sample_projects")
    }()
    
    static let previewDataSamples: [DataSample]! = {
        return try? decode(filename: "sample_datasamples")
    }()
    
    static let previewFullMicrophoneDataSampleResponse: FullDataAcquisitionData! = {
        return try? decode(filename: "sample_full_microphone_data_response")
    }()
    
    static let previewFullAccelerometerDataSampleResponse: FullDataAcquisitionData! = {
        return try? decode(filename: "sample_full_accelerometer_data_response")
    }()
    
    static let previewFullCameraDataSampleResponse: FullDataAcquisitionData! = {
        return try? decode(filename: "sample_full_camera_data_response")
    }()
    
    static let previewHelloMessage: Message! = {
        return try? decode(filename: "sample_hello_message")
    }()
    
    static let projectsPreviewAppData = previewAppData(.complete(previewUser, previewProjects))
    
    static let connectingDeviceWrapper: DeviceData.ScanResultWrapper = {
        let scanResult = ScanResult(name: "Test Device", uuid: UUID(), rssi: .outOfRange, advertisementData: .connectableMock)
        var wrapper = DeviceData.ScanResultWrapper(scanResult: scanResult)
        wrapper.state = .connecting
        return wrapper
    }()
    
    static let noDevicesAppData: AppData = {
        let appData = AppData()
        appData.loginState = .complete(previewUser, Preview.previewProjects)
        return appData
    }()
    
    static let noProjectsAppData: AppData = {
        let appData = AppData()
        appData.loginState = .complete(previewUser, [])
        return appData
    }()
    
    static let inferencingResults = InferencingResults(type: "hello", classification: [
        InferencingResults.Classification(label: "Red Bull", value: 0.5),
        InferencingResults.Classification(label: "Mercedes", value: 0.4),
        InferencingResults.Classification(label: "Ferrari", value: 0.3),
        InferencingResults.Classification(label: "Aston Martin", value: 0.75),
        InferencingResults.Classification(label: "Alpine", value: 0.6)
    ], anomaly: 0.5)
    
    static func previewAppData(_ loginState: AppData.LoginState) -> AppData {
        let appData = AppData()
        appData.apiToken = "hello"
        appData.loginState = loginState
        appData.samplesForCategory[.training] = previewDataSamples
        appData.inferencingViewState.results = [Preview.inferencingResults]
        return appData
    }
}

// MARK: - Preview

fileprivate extension Preview {
    
    static func decode<T: Decodable>(filename: String) throws -> T? {
        let path: String! = Bundle.main.path(forResource: filename, ofType: "json")
        let content: String! = try? String(contentsOfFile: path)
        let contentData: Data! = content.data(using: .utf8)
        return try? JSONDecoder().decode(T.self, from: contentData)
    }
}
#endif
