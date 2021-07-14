//
//  Color.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/7/21.
//

import SwiftUI

extension Color {
    
    static var formBackground: Color {
        #if os(OSX)
        return .white
        #elseif os(iOS)
        return Color(UIColor.systemGroupedBackground)
        #endif
    }
    
    static var secondarySystemBackground: Color {
        #if os(OSX)
        return .white
        #elseif os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #endif
    }
}
