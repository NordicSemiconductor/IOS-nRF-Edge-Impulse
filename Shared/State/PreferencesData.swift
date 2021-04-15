//
//  PreferencesData.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/4/21.
//

import SwiftUI

final class PreferencesData: ObservableObject {
    
    // MARK: - Preferences
    
    @Published var onlyScanUARTDevices: Bool {
        didSet {
            UserDefaults.standard.set(self.onlyScanUARTDevices, forKey: UserDefaultKeys.onlyScanUARTDevices)
        }
    }
    
    @Published var onlyScanConnectableDevices: Bool {
        didSet {
            UserDefaults.standard.set(self.onlyScanConnectableDevices, forKey: UserDefaultKeys.onlyScanConnectableDevices)
        }
    }
    
    // MARK: - Init
    
    init() {
        onlyScanUARTDevices = UserDefaults.standard.object(forKey: UserDefaultKeys.onlyScanUARTDevices) as? Bool ?? true
        onlyScanConnectableDevices = UserDefaults.standard.object(forKey: UserDefaultKeys.onlyScanConnectableDevices) as? Bool ?? true
    }
}

// MARK: - KeychainKeys

private extension PreferencesData {
    
    enum UserDefaultKeys: String, RawRepresentable {
        case onlyScanUARTDevices, onlyScanConnectableDevices
    }
}

// MARK: - UserDefaults

extension UserDefaults {
    
    public func object<T: RawRepresentable>(forKey key: T) -> Any? where T.RawValue == String {
        object(forKey: key.rawValue)
    }
    
    public func set<T: RawRepresentable>(_ value: Any?, forKey key: T) where T.RawValue == String {
        set(value, forKey: key.rawValue)
    }
}
