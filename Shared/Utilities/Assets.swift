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
    case textColor = "PrimaryTextColor"
    #if os(OSX)
    case projectSelectorToolbarBackground = "MacProjectSelectorBackground"
    #endif
    
    var color: Color {
        Color(rawValue)
    }
    
    #if os(iOS)
    var uiColor: UIColor! {
        UIColor(named: rawValue)
    }
    #endif
}
