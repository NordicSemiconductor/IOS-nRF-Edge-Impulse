//
//  BluetoothManager.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 24/03/2021.
//

import Foundation
import CoreBluetooth

final class BluetoothManager: NSObject {
    let peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        super.init()
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { peripheral.discoverCharacteristics(nil, for: $0) }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    }
}
