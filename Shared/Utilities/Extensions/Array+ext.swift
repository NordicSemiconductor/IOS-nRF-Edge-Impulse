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
    
    mutating func replaceOrAppend(_ element: Element) {
        if let index = firstIndex(of: element) {
            self[index] = element
        } else {
            self.append(element)
        }
    }
    
    mutating func addOrReplaceFirst(_ element: Element, where condition: (Element) -> (Bool)) {
        if let index = firstIndex(where: condition) {
            self[index] = element
        } else {
            self.append(element)
        }
    }
}
