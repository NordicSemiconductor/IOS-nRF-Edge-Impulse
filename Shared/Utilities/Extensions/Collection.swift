//
//  Collection.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 20/4/21.
//

import Foundation

// MARK: - Sequence

extension Sequence {
    
    func inverseFilter(_ isNotIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        try filter { element in
            try !isNotIncluded(element)
        }
    }
}

// MARK: - Collection Extension

extension Collection {

    var hasItems: Bool { count > 0 }
}
