//
//  Color.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/7/21.
//

import SwiftUI

extension Color {
    
    static var universalAccentColor: Color {
        #if os(OSX)
        return Color.accentColor
        #elseif os(iOS)
        return Assets.blue.color
        #endif
    }
    
    static var textColor: Color {
        #if os(OSX)
        return Color.primary
        #elseif os(iOS)
        return Color(.label)
        #endif
    }
    
    static var positiveActionButtonColor: Color {
        #if os(OSX)
        return Color.primary
        #elseif os(iOS)
        return Assets.blue.color
        #endif
    }
    
    static var negativeActionButtonColor: Color {
        return Assets.red.color
    }
    
    static var disabledTextColor: Color {
        return Assets.middleGrey.color
    }
    
    static var textFieldColor: Color {
        #if os(OSX)
        return Color.primary
        #elseif os(iOS)
        return Color(.black)
        #endif
    }
    
    static var formBackground: Color {
        #if os(OSX)
        return .clear
        #elseif os(iOS)
        return Color(UIColor.systemGroupedBackground)
        #endif
    }
    
    static var secondarySystemBackground: Color {
        #if os(OSX)
        return Color(.controlBackgroundColor)
        #elseif os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #endif
    }
    
    static var secondarySystemGroupBackground: Color {
        #if os(OSX)
        return Color(.controlBackgroundColor)
        #elseif os(iOS)
        return Color(UIColor.secondarySystemGroupedBackground)
        #endif
    }
}
