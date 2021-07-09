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
        return .black
        #elseif os(iOS)
        return Color(UIColor.systemGroupedBackground)
        #endif
    }
}
