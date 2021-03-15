//
//  NordicError.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/3/21.
//

import Foundation

struct NordicError: Error {
    
    let description: String
    
    var localizedDescription: String { description }
}
