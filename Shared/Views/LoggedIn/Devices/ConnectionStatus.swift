//
//  DeviceAccessoryView.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 18/05/2021.
//

import SwiftUI

struct ConnectionStatus: View {
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(size: CGSize(width: 12, height: 12))
    }
}

#if DEBUG
struct ConnectionStatus_Previews: PreviewProvider {
    static var previews: some View {
        Group() {
            ConnectionStatus(color: .red)
            ConnectionStatus(color: .green)
            ConnectionStatus(color: .orange)
        }
        .previewLayout(.sizeThatFits)
        
    }
}
#endif
