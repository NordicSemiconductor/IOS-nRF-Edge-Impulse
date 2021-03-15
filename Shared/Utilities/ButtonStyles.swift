//
//  ButtonStyles.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 15/3/21.
//

import SwiftUI

// MARK: - TabBarListButtonStyle

struct TabBarListButtonStyle: ButtonStyle {
    private static let Height: CGFloat = 35
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.leading, 8)
            .frame(maxWidth: .infinity, minHeight: Self.Height, maxHeight: Self.Height)
            .background(configuration.isPressed ? Assets.blue.color : Color.clear)
    }
}
