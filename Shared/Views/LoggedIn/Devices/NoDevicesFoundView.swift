//
//  NoDevicesFoundView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 14/7/21.
//

import SwiftUI

// MARK: - NoDevicesFoundView

struct NoDevicesFoundView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(.textColor)
            
            Text("Can't find your Thingy:53?")
                .font(.title3)
                .padding(.top, 4)
            
            Text("""
                1. Check that your device is charged and powered on.
                2. Check that the correct firmware is flashed into your device.
                """)
                .lineSpacing(4.0)
                .font(.body)
                .foregroundColor(Assets.middleGrey.color)
                .padding(.top)
        }
        .padding()
    }
}

// MARK: - Preview

#if DEBUG
struct NoDevicesFoundView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoDevicesFoundView()
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
