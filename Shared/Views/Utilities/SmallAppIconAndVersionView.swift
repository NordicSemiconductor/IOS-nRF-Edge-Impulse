//
//  AppIconView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 1/7/21.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - SmallAppIconAndVersionView

struct SmallAppIconAndVersionView: View {
    
    var body: some View {
        HStack {
            AppIconView()
                .saturation(0.3)
                .frame(width: 16, height: 16)
            Text(Constant.appVersion)
                .font(.caption)
        }
    }
}

// MARK: - Preview

struct SmallAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SmallAppIconAndVersionView()
        }
        .previewLayout(.sizeThatFits)
    }
}
