//
//  CircularProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 24/9/21.
//

import SwiftUI

// MARK: - CircularProgressView

struct CircularProgressView: View {
    
    private let tintColor: Color
    
    // MARK: Init
    
    init(tintColor: Color = .textColor) {
        self.tintColor = tintColor
    }
    
    // MARK: iOS
    
    #if os(iOS)
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
            .frame(width: 20, height: 20)
    }
    #endif
    
    // MARK: macOS
    
    #if os(macOS)
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
            .scaleEffect(0.5, anchor: .center)
    }
    #endif
}

// MARK: - Preview

#if DEBUG
struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView()
    }
}
#endif
