//
//  NoRegisteredDevicesView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 3/12/21.
//

import SwiftUI

// MARK: - NoRegisteredDevicesView

struct NoRegisteredDevicesView: View {
    var body: some View {
        VStack {
            Image(systemName: "arrow.turn.up.forward.iphone")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(Assets.textColor.color)
            
            Text("No Registered Devices")
                .font(.title3)
                .padding(.top, 4)
            
            Text("""
                There are no devices registered with this project yet.
                
                If you connect to a device from the section below, we'll auto-magically add it for you.
                """)
                .lineSpacing(4.0)
                .font(.body)
                .foregroundColor(Assets.middleGrey.color)
                .padding(.top)
        }
        .padding()
        #if os(macOS)
        .background(Color.secondarySystemBackground)
        #endif
    }
}

// MARK: - Preview

#if DEBUG
struct NoRegisteredDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoRegisteredDevicesView()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
