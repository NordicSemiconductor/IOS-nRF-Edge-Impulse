//
//  MacAddressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 24/8/21.
//

import SwiftUI

struct MacAddressView: View {
    
    // MARK: - body
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            
            Text("Your MAC Address:")
                .font(.footnote)
                .fontWeight(.light)
            
            Text(MacAddress.shared.get() ?? "N/A")
                .font(.footnote)
            
            Spacer()
        }
        .padding(.bottom, 10)
    }
}

// MARK: - Preview

#if DEBUG
struct MacAddressView_Previews: PreviewProvider {
    
    static var previews: some View {
        MacAddressView()
            .previewLayout(.sizeThatFits)
    }
}
#endif
