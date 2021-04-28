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
    
    static let unselectedProject = Project.Sample
    static let unselectedDevice = Device(name: "", id: UUID(), rssi: .outOfRange, advertisementData: AdvertisementData())
    
    // MARK: - URL(s)
    
    static let signupURL: URL! = URL(string: "https://studio.edgeimpulse.com/signup")
    static let forgottenPasswordURL: URL! = URL(string: "https://studio.edgeimpulse.com/forgot-password")
    
    // MARK: - App
    
    static let appName: String = {
        return Bundle(for: AppData.self).object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? "nRF Edge Impulse"
    }()
    
    static let aboutEdgeImpulse: String = {
       return "We are easy to reach!\n\nTo contact us, holler us on Twitter @NordicTweets. You can also use our DevZone forums (devzone.nordicsemi.com) where you will receive quick support for your inquiries."
    }()
    
    static let copyright: String = {
        return "Copyright © \(Date.currentYear()) Nordic Semiconductor ASA"
    }()
}

// MARK: - Size(s)

extension CGSize {
    
    static let SmallImageSize = CGSize(width: 15, height: 15)
    static let ToolbarImageSize = CGSize(width: 30, height: 30)
    static let StandardImageSize = CGSize(width: 40, height: 40)
}
