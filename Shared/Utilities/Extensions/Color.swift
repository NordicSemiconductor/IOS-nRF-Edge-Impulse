//
//  Color.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/7/21.
//

import SwiftUI
import iOS_Common_Libraries

extension Color {
    
    static var universalAccentColor: Color {
        #if os(OSX)
        return Color.accentColor
        #elseif os(iOS)
        return Assets.blue.color
        #endif
    }
    
    static var positiveActionButtonColor: Color {
        #if os(OSX)
        return Color.primary
        #elseif os(iOS)
        return Assets.blue.color
        #endif
    }
    
    static var negativeActionButtonColor: Color { Assets.red.color }
    
    static var succcessfulActionButtonColor: Color { Assets.blue.color }
    
    static var disabledTextColor: Color { Assets.middleGrey.color }
}
