//
//  CircleImageView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI

struct CircleImage: View {
    
    let image: Image
    
    // MARK: - @viewBuilder
    
    var body: some View {
        image
            .resizable()
            .frame(width: 100, height: 100, alignment: .leading)

            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 5))
            .shadow(radius: 7)
            .padding()
    }
}

// MARK: - Preview

#if DEBUG
struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(image: Image("EdgeImpulse"))
    }
}
#endif
