//
//  CircleImageView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI

struct CircleImage: View {
    
    let image: Image
    let size: CGSize
    
    // MARK: - @viewBuilder
    
    var body: some View {
        image
            .resizable()
            .frame(width: size.width, height: size.height)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .shadow(radius: 2)
            .padding()
    }
}

// MARK: - Preview

#if DEBUG
struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(image: Image("EdgeImpulse"), size: CGSize(width: 100, height: 100))
    }
}
#endif
