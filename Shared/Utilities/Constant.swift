//
//  Constant.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/3/21.
//

import Foundation
import CoreGraphics
import iOS_Common_Libraries

// MARK: - Constant

extension Constant {
    
    // MARK: - Unselected
    
    static let unselectedProject: Project! = Project.Unselected
    static let unselectedScanResult = ScanResult(name: "Unselected", uuid: UUID(), rssi: .outOfRange, advertisementData: AdvertisementData())
    static let unselectedDevice = Device.Unselected
    static let unselectedSensor = Sensor(name: "Unselected", maxSampleLengthS: 0, frequencies: [])
    static let unselectedSampleLength: Double = 0.0
    static let unselectedFrequency: Double = 0.0
    
    // MARK: - App
    
    static let appName = Constant.appName(forBundleWithClass: AppData.self)
    static let appVersion = Constant.appVersion(forBundleWithClass: AppData.self)
    
    static let aboutEdgeImpulse: String = {
       return "We are easy to reach!\n\nTo contact us, holler us on Twitter @NordicTweets. You can also use our DevZone forums (devzone.nordicsemi.com) where you will receive quick support for your inquiries."
    }()
}

// MARK: - CGFloat

extension CGFloat {
    
    static let minTabWidth: Self = {
        let value: CGFloat
        #if os(OSX)
        value = 400
        #else
        value = 320
        #endif
        return value
    }()
    
    static let sidebarWidth: Self = 160
    
    static let maxTextFieldWidth: Self = 350
}

// MARK: - Size(s)

extension CGSize {
    
    static let SmallImageSize = CGSize(width: 15, height: 15)
    static let ToolbarImageSize = CGSize(width: 30, height: 30)
    static let StandardImageSize = CGSize(width: 40, height: 40)
    
    static let TableViewPaddingSize = CGSize(width: 0, height: 8)
}

// MARK: - TimeInterval

extension TimeInterval {
    
    static let timeoutInterval: Self = 45.0
}
