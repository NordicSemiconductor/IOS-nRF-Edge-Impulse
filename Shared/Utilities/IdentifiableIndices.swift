//
//  IdentifiableIndices.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 18/3/21.
//

import Foundation
import SwiftUI

// MARK: - IdentifiableIndices

struct IdentifiableIndices<Base: RandomAccessCollection>
    where Base.Element: Identifiable {

    typealias Index = Base.Index

    struct Element: Identifiable {
        let id: Base.Element.ID
        let rawValue: Index
    }

    fileprivate var base: Base
}

// MARK: - RandomAccessCollection

extension IdentifiableIndices: RandomAccessCollection {
    
    var startIndex: Index { base.startIndex }
    var endIndex: Index { base.endIndex }

    subscript(position: Index) -> Element {
        Element(id: base[position].id, rawValue: position)
    }

    func index(before index: Index) -> Index {
        base.index(before: index)
    }

    func index(after index: Index) -> Index {
        base.index(after: index)
    }
}

// MARK: - @identifiableIndices

extension RandomAccessCollection where Element: Identifiable {
    var identifiableIndices: IdentifiableIndices<Self> {
        IdentifiableIndices(base: self)
    }
}

// MARK: - ForEach

extension ForEach where ID == Data.Element.ID, Data.Element: Identifiable, Content: View {
    
    init<T>(_ indices: Data, @ViewBuilder content: @escaping (Data.Index) -> Content) where Data == IdentifiableIndices<T> {
        self.init(indices) { index in
            content(index.rawValue)
        }
    }
}
