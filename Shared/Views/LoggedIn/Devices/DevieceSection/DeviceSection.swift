//
//  DeviceSection.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 06/08/2021.
//

import SwiftUI

struct DeviceSection<Content: View, D: Identifiable>: View {
    let title: String
    let data: [D]
    let content: (D) -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8, content: {
            Text(title.uppercased()).font(.subheadline)
            
            if data.hasItems {
                VStack(spacing: 0) {
                    ForEach(data) { d in
                        dataView(d)
                            .background(Color.secondarySystemGroupBackground)
                        Divider()
                    }
                }
                .cornerRadius(10)
            } else {
                NoDevicesView().padding()
            }
        })
        .padding()
    }
    
    @ViewBuilder
    func dataView(_ d: D) -> some View {
        content(d)
    }
}

#if DEBUG
struct DeviceSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeviceSection(
                title: "Scan Results",
                data: [ScanResult.sample, ScanResult.sample]) { d in
                DeviceRow(d)
            }
            DeviceSection(
                title: "Scan Results",
                data: []) { d in
                DeviceRow(d)
            }
        }
        .background(Color.formBackground)
        .previewLayout(.sizeThatFits)
    }
}

#endif
