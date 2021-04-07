//
//  CBCentralManager+Ext.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Nick Kibysh on 07/04/2021.
//

import Foundation
import CoreBluetooth

extension CBManagerState: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        switch self {
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        case .resetting:
            return "resetting"
        case .unauthorized:
            return "unauthorized"
        case .unknown:
            return "unknown"
        case .unsupported:
            return "unsupported"
        @unknown default:
            return "unknownState"
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
    
}
