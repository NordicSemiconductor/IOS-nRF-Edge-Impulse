//
//  Modifiers.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/4/21.
//

import SwiftUI

// MARK: - Placeholder

public struct FixPlaceholder: ViewModifier {
    
    private var contentString: Binding<String>
    private var placeholderText: String

    // MARK: - Init
    
    init(for binding: Binding<String>, text: String) {
        self.contentString = binding
        self.placeholderText = text
    }
    
    // MARK: - ViewModifier
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if contentString.wrappedValue.isEmpty {
                Text(placeholderText)
                    .foregroundColor(.gray)
            }
            
            content
        }
    }
}

