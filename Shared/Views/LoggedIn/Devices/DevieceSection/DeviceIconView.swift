//
//  DeviceIconView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 25/8/21.
//

import SwiftUI

// MARK: - DeviceIconView

struct DeviceIconView: View {
    
    // MARK: Properties
    
    let name: String
    let color: Color
    
    // MARK: View
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
            
            Image(systemName: name)
                .resizable()
                .frame(size: CGSize(width: 24, height: 24))
                .foregroundColor(.white)
        }
        .frame(size: CGSize(width: 40, height: 40))
    }
}


// MARK: - Preview

#if DEBUG
struct DeviceIconView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeviceIconView(name: "cpu", color: .gray)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
