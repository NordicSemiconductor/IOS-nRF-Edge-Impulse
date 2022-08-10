//
//  ViewModifiers.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/6/21.
//

import SwiftUI

// MARK: - View

extension View {
    
    func enabledForeground(_ enabled: Bool) -> some View {
        modifier(EnabledForegroundView(enabled: enabled))
    }
    
    func enabledAccent(_ enabled: Bool) -> some View {
        modifier(EnabledAccentView(enabled: enabled))
    }
}

// MARK: - EnabledTextView

struct EnabledForegroundView: ViewModifier {
    
    let enabled: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(enabled ? Assets.textColor.color : .disabledTextColor)
            .accentColor(.nordicBlue)
            .disabled(!enabled)
    }
}

// MARK: - EnabledAccentView

struct EnabledAccentView: ViewModifier {
    
    let enabled: Bool
    
    func body(content: Content) -> some View {
        content
            .accentColor(enabled ? .universalAccentColor : .disabledTextColor)
            .disabled(!enabled)
    }
}

// MARK: - CircularButtonShape

struct CircularButtonShape: ViewModifier {
    
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
        #if os(iOS)
            .frame(width: 80, height: 12)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(backgroundColor)
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
    
    private let backgroundColor: Color
    private let hasTextFieldBelow: Bool
    
    init(_ backgroundColor: Color, hasTextFieldBelow: Bool = false) {
        self.backgroundColor = backgroundColor
        self.hasTextFieldBelow = hasTextFieldBelow
    }
    
    func body(content: Content) -> some View {
        content
        #if os(iOS)
            .frame(maxWidth: 320)
            .frame(height: 20)
            .padding()
            .background(backgroundColor)
            .cornerRadius(30)
            .padding(.bottom, hasTextFieldBelow ? 16 : 0)
        #endif
    }
}
