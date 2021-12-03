//
//  DeviceSection.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 06/08/2021.
//

import SwiftUI

struct DeviceSection<Content: View, D: Identifiable>: View {
    
    let title: String?
    let data: [D]
    let content: (D) -> Content
    
    init(title: String? = nil, data: [D], content: @escaping (D) -> Content) {
        self.title = title
        self.data = data
        self.content = content
    }
    
    var body: some View {
        Section(header: Text(title ?? "")) {
            ForEach(data) { wrapper in
                content(wrapper)
            }
            
            if data.isEmpty {
                NoDevicesFoundView()
                    .padding()
            }
        }
    }
}

#if DEBUG
struct DeviceSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeviceSection(
                title: "Scan Results",
                data: [DeviceData.ScanResultWrapper(scanResult: .sample), DeviceData.ScanResultWrapper(scanResult: .sample)]) { d in
                UnregisteredDeviceView(d)
            }
            DeviceSection(
                title: "Scan Results",
                data: []) { d in
                UnregisteredDeviceView(d)
            }
        }
        .background(Color.formBackground)
        .previewLayout(.sizeThatFits)
    }
}

#endif
