//
//  PreferencesData.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/4/21.
//

import Foundation
import KeychainSwift

final class PreferencesData: ObservableObject {
    
    // MARK: - Preferences
    
    @Published var onlyScanUARTDevices: Bool {
        didSet {
            guard !Constant.isRunningInPreviewMode else { return }
            keychain.set(onlyScanUARTDevices, forKey: KeychainKeys.onlyScanUARTDevices.rawValue)
        }
    }
    @Published var onlyScanConnectableDevices: Bool {
        didSet {
            guard !Constant.isRunningInPreviewMode else { return }
            keychain.set(onlyScanConnectableDevices, forKey: KeychainKeys.onlyScanConnectableDevices.rawValue)
        }
    }
    
    // MARK: - Private Properties
    
    private var keychain: KeychainSwift
    
    // MARK: - Init
    
    init() {
        let keychain = KeychainSwift()
        
        self.onlyScanUARTDevices = keychain.getBool(KeychainKeys.onlyScanUARTDevices.rawValue) ?? true
        self.onlyScanConnectableDevices = keychain.getBool(KeychainKeys.onlyScanConnectableDevices.rawValue) ?? true
        self.keychain = keychain
    }
}

// MARK: - KeychainKeys

private extension PreferencesData {
    
    enum KeychainKeys: String, RawRepresentable {
        case onlyScanUARTDevices, onlyScanConnectableDevices
    }
}
