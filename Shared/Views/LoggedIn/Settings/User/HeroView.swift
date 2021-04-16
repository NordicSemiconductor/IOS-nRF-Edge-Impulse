//
//  UserHeroView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI

struct HeroView: View {
    
    static let ImageSize = CGSize(width: 60, height: 60)
    
    let user: User
    
    var body: some View {
        ZStack {
            Image("EdgeImpulseFull")
                .resizable()
                .scaledToFit()
                .brightness(-1.0)
                .blur(radius: 25)
            HStack {
                CircleAround(URLImage(url: user.photo, placeholderImage: Image("EdgeImpulse")))
                    .frame(width: HeroView.ImageSize.width,
                           height: HeroView.ImageSize.height)
                    .padding()

                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Joined \(user.createdSince)")
                        .font(.callout)
                        .fontWeight(.light)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(height: 2 * HeroView.ImageSize.height)
    }
}

// MARK: - Preview

#if DEBUG
struct HeroView_Previews: PreviewProvider {
    
    static let userWithoutImage = User(id: 8, username: "dinesh.harjani", created: Date())
    static let userWithImage = User(id: 5, username: "taylor.swift", created: Date(),
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
