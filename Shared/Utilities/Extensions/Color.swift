//
//  Color.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/7/21.
//

import SwiftUI

extension Color {
    
    static var textColor: Color {
        #if os(OSX)
        return Color.primary
        #elseif os(iOS)
        return Color(.label)
        #endif
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
}
