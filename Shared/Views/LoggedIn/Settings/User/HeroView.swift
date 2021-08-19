//
//  UserHeroView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI
import VisualEffects

struct HeroView: View {
    
    let user: User
    
    #if os(OSX)
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.clear, Assets.sky.color]),
                           startPoint: .leading, endPoint: .trailing)
            VisualEffectBlur()
            UserView(user: user)
        }
        .frame(height: 1.25 * UserView.ImageSize.height)
        .cornerRadius(8.0, antialiased: true)
    }
    #else
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Assets.blue.color, Assets.grass.color, .yellow, Assets.red.color]),
                startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VisualEffectBlur(blurStyle: .systemThickMaterial, vibrancyStyle: .none) {
                UserView(user: user)
                    .padding(.horizontal)
            }
        }
        .frame(height: 2 * UserView.ImageSize.height)
    }
    #endif
}

// MARK: - Preview

#if DEBUG
struct HeroView_Previews: PreviewProvider {
    
    static let userWithoutImage = User(id: 8, username: "dinesh.harjani", name: "Dinesh Harjani", created: Date())
    static let userWithImage = User(id: 5, username: "taylor.swift", name: "Taylor Swift", created: Date(),
                                    photo: "https://avatarfiles.alphacoders.com/169/169651.jpg")
    
    static var previews: some View {
        Group {
            HeroView(user: HeroView_Previews.userWithoutImage)
            HeroView(user: HeroView_Previews.userWithImage)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
