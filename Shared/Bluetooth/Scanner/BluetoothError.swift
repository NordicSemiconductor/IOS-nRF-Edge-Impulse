//
//  BluetoothError.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/3/21.
//

import Foundation

public enum BluetoothError: Error {
    case bluetoothPoweredOff
    case failedToConnect, failedToDiscoverCharacteristics, failedToDiscoverServices
    case noCharacteristicsForService, noServicesForPeripheral
}
