//
//  Constant.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/3/21.
//

import Foundation

// MARK: - Constant

enum Constant {
    
    // MARK: - Preview
    
    static var isRunningInPreviewMode: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // MARK: - Unselected
    
    static let unselectedProject = Project.Sample
    static let unselectedDevice = ScanResult(name: "", id: UUID(), rssi: .outOfRange, advertisementData: AdvertisementData())
    
    // MARK: - URL(s)
    
    static let signupURL: URL! = URL(string: "https://studio.edgeimpulse.com/signup")
    static let forgottenPasswordURL: URL! = URL(string: "https://studio.edgeimpulse.com/forgot-password")
}
