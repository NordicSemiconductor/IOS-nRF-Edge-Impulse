//
//  PreferencesData.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/4/21.
//

import Foundation

final class PreferencesData: ObservableObject {
    
    @Published var onlyScanUARTDevices = true
    @Published var onlyScanConnectableDevices = true
}
