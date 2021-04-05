//
//  UserView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI

struct UserView: View {
    
    static let ImageSize = CGSize(width: 50, height: 50)
    
    let user: User
    
    var body: some View {
        ZStack {
            Image("EdgeImpulseFull")
                .resizable()
                .scaledToFit()
                .brightness(-1.0)
                .blur(radius: 25)
            HStack {
                CircleImage(image: Image("EdgeImpulse"), size: UserView.ImageSize)

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
        .frame(height: 2 * UserView.ImageSize.height)
    }
}

// MARK: - Preview

#if DEBUG
struct UserView_Previews: PreviewProvider {
    
    static let userWithoutImage = User(id: 5, username: "taylor.swift", created: Date())
    static let userWithImage = User(id: 8, username: "dinesh.harjani", created: Date())
    
    static var previews: some View {
        Group {
            UserView(user: UserView_Previews.userWithoutImage)
            UserView(user: UserView_Previews.userWithImage)
        }
    }
}
#endif
