//
//  MacAddress.swift
//  nRF-Edge-Impulse (macOS)
//
//  Created by Dinesh Harjani on 24/8/21.
//

import Foundation
import IOBluetooth

final class MacAddress {
    
    static let shared = MacAddress()
    
    // MARK: - Private
    
    private let controller: IOBluetoothHostController
    private var address: String?
    
    private init() {
        self.controller = IOBluetoothHostController.default()
    }
    
    func get() -> String? {
        guard address == nil else { return address }

        address = controller.addressAsString().uppercased()
        return address
    }
}
