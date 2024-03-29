//
//  UserView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 23/3/21.
//

import SwiftUI
import Combine
import iOS_Common_Libraries

struct UserView: View {
    
    static let ImageSize = CGSize(width: 40, height: 40)
    
    // MARK: - Properties
    
    let user: User
    @EnvironmentObject var appData: AppData
    
    // MARK: - View
    
    var body: some View {
        HStack(spacing: 16) {
            CircleAround(URLImage(url: user.photo, placeholderImage: Image("EdgeImpulse")))
                .frame(width: UserView.ImageSize.width,
                       height: UserView.ImageSize.width)

            VStack(alignment: .leading, spacing: 4) {
                Text(user.formattedName)
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Joined \(user.created.formatterString(dateStyle: .medium, timeStyle: .none))")
                    .font(.callout)
                    .foregroundColor(.nordicMiddleGrey)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("(\(user.createdSince))")
                    .font(.callout)
                    .fontWeight(.light)
                    .foregroundColor(.nordicMiddleGrey)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}



// MARK: - Preview

#if DEBUG
struct UserView_Previews: PreviewProvider {
    
    static let loggedInWithoutUser: AppData = {
        let appData = AppData()
        appData.apiToken = "A"
        appData.loginState = .empty
        return appData
    }()
    
    static var previews: some View {
        Group {
            UserView(user: Preview.previewUser)
        }
        .frame(width: 300)
        .previewLayout(.sizeThatFits)
    }
}
#endif
