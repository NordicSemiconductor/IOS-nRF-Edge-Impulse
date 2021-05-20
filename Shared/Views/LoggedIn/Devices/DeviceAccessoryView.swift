//
//  DeviceAccessoryView.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 18/05/2021.
//

import SwiftUI

struct DeviceAccessoryView: View {
    enum DeviceType {
        case scanResult, known, connected, inProcess
    }
    
    let deviceType: DeviceType
    
    var body: some View {
        switch deviceType {
        case .known:
            Circle()
                .fill(Color.red)
                .frame(size: CGSize(width: 12, height: 12))
        case .connected:
            Circle()
                .fill(Color.green)
                .frame(size: CGSize(width: 12, height: 12))
        case .scanResult:
            Text("")
        case .inProcess:
            ProgressView()
        }
    }
}

#if DEBUG
struct DeviceAccessoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group() {
            DeviceAccessoryView(deviceType: .connected)
            DeviceAccessoryView(deviceType: .known)
            DeviceAccessoryView(deviceType: .inProcess)
            DeviceAccessoryView(deviceType: .scanResult)
        }
        .previewLayout(.sizeThatFits)
        
    }
}
#endif
