//
//  DeviceSection.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 06/08/2021.
//

import SwiftUI

// MARK: - DeviceSection

struct DeviceSection<Content: View, EmptyContent: View, D: Identifiable>: View {
    
    private let title: String?
    private let data: [D]
    private let emptyContentView: EmptyContent
    private let content: (D) -> Content
    
    // MARK: Init
    
    init(title: String? = nil, data: [D], emptyContentView: EmptyContent,
         content: @escaping (D) -> Content) {
        self.title = title
        self.data = data
        self.emptyContentView = emptyContentView
        self.content = content
    }
    
    // MARK: View
    
    var body: some View {
        Section(header: Text(title ?? "")) {
            ForEach(data) { wrapper in
                content(wrapper)
            }
            
            if data.isEmpty {
                emptyContentView
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DeviceSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeviceSection(
                title: "Scan Results",
                data: [DeviceData.ScanResultWrapper(scanResult: .sample), DeviceData.ScanResultWrapper(scanResult: .sample)], emptyContentView: NoDevicesFoundView()) { d in
                UnregisteredDeviceView(d)
            }
            DeviceSection(
                title: "Scan Results",
                data: [], emptyContentView: NoRegisteredDevicesView()) { d in
                UnregisteredDeviceView(d)
            }
        }
        .background(Color.formBackground)
        .previewLayout(.sizeThatFits)
    }
}

#endif
