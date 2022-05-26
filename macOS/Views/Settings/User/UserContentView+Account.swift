//
//  UserContentView+Account.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/5/22.
//

import SwiftUI

#if os(macOS)
extension UserContentView {
    
    @ViewBuilder
    func macOSAccountSectionView() -> some View {
        Section(content: {
            HStack {
                VStack {
                    Image(systemName: "person.badge.clock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                    
                    Button("Logout", action: logout)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Divider()
                    .foregroundColor(Assets.lightGrey.color)
                
                VStack {
                    Image(systemName: "person.badge.minus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30, alignment: .center)
                    
                    Button("Delete", action: showDeleteUserAccountAlert)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundColor(.negativeActionButtonColor)
            }
            .padding(4)
            .withTabBarStyle()
        }, header: {
            Text("Account")
        }, footer: {
            Text(Strings.accountDeletionFooter)
                .font(.body)
                .foregroundColor(Assets.middleGrey.color)
        })
    }
}
#endif
