//
//  NordicColor.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/3/21.
//

import SwiftUI

// MARK: - Assets

enum Assets: String {
    
    // MARK: - Colors
    
    case navBarBackground = "NavBar"
    
    case blue = "NordicBlue"
    case sky = "NordicSky"
    case blueslate = "NordicBlueslate"
    case lake = "NordicLake"
    
    case grass = "NordicGrass"
    case sun = "NordicSun"
    case red = "NordicRed"
    case fall = "NordicFall"
    
    case lightGrey = "NordicLightGrey"
    case middleGrey = "NordicMiddleGrey"
    case darkGrey = "NordicDarkGrey"
    
    var color: Color {
        Color(rawValue)
    }
    
    #if os(iOS)
    var uiColor: UIColor! {
        UIColor(named: rawValue)
    }
    #endif
}
