//
//  AppHeaderView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/4/21.
//

import SwiftUI

struct AppHeaderView: View {
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image("Nordic")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
            
            Divider()
                .foregroundColor(Assets.lightGrey.color)
                .frame(width: 2, height: 60)
                .padding(.leading, 12)
            
            Image("EdgeImpulse")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AppHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        AppHeaderView()
            .previewLayout(.sizeThatFits)
    }
}
#endif
