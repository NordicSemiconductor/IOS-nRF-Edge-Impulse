//
//  Array+ext.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 16/06/2021.
//

import Foundation

extension Array where Element : Equatable & Hashable {
    
    @discardableResult
    mutating func appendDistinct(_ element: Element) -> Bool {
        if !self.contains(element) {
            self.append(element)
            return true
        } else {
            return false
        }
    }
}
