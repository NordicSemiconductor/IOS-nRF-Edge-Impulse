//
//  ViewModifiers.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/6/21.
//

import SwiftUI

// MARK: - CircularButtonShape

struct CircularButtonShape: ViewModifier {
    
    let backgroundAsset: Assets
    
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .frame(width: 80, height: 12)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(backgroundAsset.color)
            .cornerRadius(30)
        #else
        self
        #endif
    }
}

// MARK: - RoundedTextFieldShape

struct RoundedTextFieldShape: ViewModifier {
    
    private let backgroundAsset: Assets
    private let hasTextFieldBelow: Bool
    
    init(_ backgroundAsset: Assets, hasTextFieldBelow: Bool = false) {
        self.backgroundAsset = backgroundAsset
        self.hasTextFieldBelow = hasTextFieldBelow
    }
    
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .frame(maxWidth: 320)
            .frame(height: 20)
            .padding()
            .background(backgroundAsset.color)
            .cornerRadius(30)
            .padding(.bottom, hasTextFieldBelow ? 16 : 0)
        #else
        self
        #endif
    }
}
