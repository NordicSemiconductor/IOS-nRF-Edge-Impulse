//
//  UserView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI

struct UserView: View {
    
    let user: User
    
    var body: some View {
        ZStack {
            Image("EdgeImpulseFull")
                .resizable()
                .scaledToFit()
                .blur(radius: 25)
            HStack {
                CircleImage(image: Image("EdgeImpulse"))
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.title)
                        .bold()
                    Text("Joined [XX] ago")
                        .font(.callout)
                        .fontWeight(.light)
                }
            }
            .padding()
        }
        .frame(height: 150)
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
