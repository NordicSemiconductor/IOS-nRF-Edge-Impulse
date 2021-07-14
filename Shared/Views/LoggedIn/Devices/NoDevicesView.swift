//
//  NoDevicesView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/7/21.
//

import SwiftUI

// MARK: - NoDevicesView

struct NoDevicesView: View {
    
    var body: some View {
        Text("No Devices")
            .font(.callout)
            .foregroundColor(Assets.middleGrey.color)
            .centerTextInsideForm()
    }
}

// MARK: - Preview

#if DEBUG
struct NoDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoDevicesView()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
