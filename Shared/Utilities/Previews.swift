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
    
    static let projectsPreviewAppData = previewAppData(.complete(previewUser, previewProjects))
    
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
    
    static func previewAppData(_ loginState: AppData.LoginState) -> AppData {
        let appData = AppData()
        appData.apiToken = "hello"
        appData.loginState = loginState
        appData.samplesForCategory[.training] = previewDataSamples
        return appData
    }
    
    // MARK: - ScannerData
    
    static let noDevicesScannerData: ScannerData = {
        let scannerData = ScannerData()
        scannerData.isScanning = false
        scannerData.scanResults = []
        return scannerData
    }()
    
    static let isScanningButNoDevicesScannerData: ScannerData = {
        let scannerData = ScannerData()
        scannerData.isScanning = true
        scannerData.scanResults = []
        return scannerData
    }()

    static var mockScannerData: ScannerData = {
        let scannerData = ScannerData()
        scannerData.isScanning = false
        scannerData.scanResults = [
            Device(name: "Device 1", id: UUID(), rssi: .good, advertisementData: .mock),
            Device(name: "Device 2", id: UUID(), rssi: .bad, advertisementData: .mock),
            Device(name: "Device 3", id: UUID(), rssi: .ok, advertisementData: .mock)
        ]
        return scannerData
    }()
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
