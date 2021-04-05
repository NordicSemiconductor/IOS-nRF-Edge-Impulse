//
//  CircleAround.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI

struct CircleAround<T: View>: View {
    
    private let view: T
    
    // MARK: - Init
    
    init(_ view: T) {
        self.view = view
    }
    
    // MARK: - View
    
    var body: some View {
        view
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 2)
    }
}

// MARK: - Preview

#if DEBUG
struct CircleAround_Previews: PreviewProvider {
    static var previews: some View {
        CircleAround(Image("EdgeImpulse").aspectRatio(contentMode: .fit))
            .fixedSize()
    }
}
#endif
