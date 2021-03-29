//
//  UUIDMapping.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 29/3/21.
//

import Foundation

struct UUIDMapping: Identifiable, Codable {
    
    var id: String { uuid }
    
    let uuid: String
    let name: String
}
