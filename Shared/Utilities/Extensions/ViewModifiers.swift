//
//  ViewModifiers.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/6/21.
//

import SwiftUI

// MARK: - EnabledTextView

struct EnabledTextView: ViewModifier {
    
    let enabled: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(enabled ? .textColor : .disabledTextColor)
            .disabled(!enabled)
    }
}

// MARK: View

extension View {
    
    func textEnabled(_ enabled: Bool) -> some View {
        modifier(EnabledTextView(enabled: enabled))
    }
}

// MARK: - CircularButtonShape

struct CircularButtonShape: ViewModifier {
    
    let backgroundAsset: Assets
    
    func body(content: Content) -> some View {
        content
        #if os(iOS)
            .frame(width: 80, height: 12)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(backgroundAsset.color)
            .cornerRadius(30)
        #endif
    }
}

// MARK: - IconOnTheRightLabelStyle

struct IconOnTheRightLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
        }
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
        content
        #if os(iOS)
            .frame(maxWidth: 320)
            .frame(height: 20)
            .padding()
            .background(backgroundAsset.color)
            .cornerRadius(30)
            .padding(.bottom, hasTextFieldBelow ? 16 : 0)
        #endif
    }
}
