//
//  Constant.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/3/21.
//

import Foundation
import CoreGraphics

// MARK: - Constant

enum Constant {
    
    // MARK: - Preview
    
    static var isRunningInPreviewMode: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // MARK: - Unselected
    
    static let unselectedProject: Project! = Project.Unselected
    static let unselectedScanResult = ScanResult(name: "Unselected", uuid: UUID(), rssi: .outOfRange, advertisementData: AdvertisementData())
    static let unselectedDevice = Device.Unselected
    static let unselectedSensor = Sensor(name: "Unselected", maxSampleLengthS: 0, frequencies: [])
    static let unselectedSampleLength: Double = 0.0
    static let unselectedFrequency: Double = 0.0
    
    // MARK: - URL(s)
    
    static let signupURL: URL! = URL(string: "https://studio.edgeimpulse.com/signup")
    static let forgottenPasswordURL: URL! = URL(string: "https://studio.edgeimpulse.com/forgot-password")
    
    // MARK: - App
    
    static let appName: String = {
        return Bundle(for: AppData.self).object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? "nRF Edge Impulse"
    }()
    
    static let appVersion: String = {
        guard let versionNumber = Bundle(for: AppData.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
              let buildNumber = Bundle(for: AppData.self).object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            return "N/A"
        }
        return "\(versionNumber) (#\(buildNumber))"
    }()
    
    static let aboutEdgeImpulse: String = {
       return "We are easy to reach!\n\nTo contact us, holler us on Twitter @NordicTweets. You can also use our DevZone forums (devzone.nordicsemi.com) where you will receive quick support for your inquiries."
    }()
    
    static let copyright: String = {
        return "Copyright © \(Date.currentYear()) Nordic Semiconductor ASA"
    }()
}

// MARK: - CGFloat

extension CGFloat {
    
    static let minTabWidth: CGFloat = {
        let value: CGFloat
        #if os(OSX)
        value = 400
        #else
        value = 320
        #endif
        return value
    }()
    
    static let sidebarWidth: CGFloat = 160
    
    static let maxTextFieldWidth: CGFloat = 350
}

// MARK: - Size(s)

extension CGSize {
    
    static let SmallImageSize = CGSize(width: 15, height: 15)
    static let ToolbarImageSize = CGSize(width: 30, height: 30)
    static let StandardImageSize = CGSize(width: 40, height: 40)
}

// MARK: - TimeInterval

extension TimeInterval {
    
    static let timeoutInterval: Self = 25.0
}
