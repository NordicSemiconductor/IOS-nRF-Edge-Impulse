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
        Divider()
        
        Section(content: {
            Button("Logout", action: logout)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Button("Delete", action: showDeleteUserAccountAlert)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.negativeActionButtonColor)
                .padding(.top)
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
