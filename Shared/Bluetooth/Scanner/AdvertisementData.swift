//
//  AdvertisementData.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 25/03/2021.
//

import Foundation
import CoreBluetooth

struct AdvertisementData {
    let localName: String? // CBAdvertisementDataLocalNameKey
    let manufacturerData: Data? // CBAdvertisementDataManufacturerDataKey
    let serviceData: [CBUUID : Data]? // CBAdvertisementDataServiceDataKey
    let serviceUUIDs: [CBUUID]? // CBAdvertisementDataServiceUUIDsKey
    let overflowServiceUUIDs: [CBUUID]? // CBAdvertisementDataOverflowServiceUUIDsKey
    let txPowerLevel: Int? // CBAdvertisementDataTxPowerLevelKey
    let isConnectable: Bool? // CBAdvertisementDataIsConnectable
    let solicitedServiceUUIDs: [CBUUID]? // CBAdvertisementDataSolicitedServiceUUIDsKey
    
    init() {
        self.init([:])
    }
    
    init(_ advertisementData: [String : Any]) {
        localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID : Data]
        serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
        overflowServiceUUIDs = advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID]
        txPowerLevel = (advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber)?.intValue
        isConnectable = (advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue
        solicitedServiceUUIDs = advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID]
    }
    
    func advertisedID() -> String? {
        guard let data = manufacturerData, data.count > 2 else { return nil }
        return data.suffix(from: 2).hexEncodedString(separator: ":").uppercased()
    }
}

#if DEBUG
extension AdvertisementData {
    static var mock: AdvertisementData {
        AdvertisementData(
            [
                CBAdvertisementDataLocalNameKey : "Device 1",
                CBAdvertisementDataIsConnectable : NSNumber.init(value: true)
            ]
        )
    }
}
#endif
