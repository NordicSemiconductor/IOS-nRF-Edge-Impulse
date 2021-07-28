//
//  RegisteredDeviceRow.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 28/07/2021.
//

import SwiftUI

struct RegisteredDeviceRow: View {
    let device: Device
    let state: DeviceData.DeviceWrapper.State
    let selection: Binding<Int?>
    
    var body: some View {
        mainBody()
            .contentShape(Rectangle())
            .onTapGesture {
                selection.wrappedValue = device.id
            }
    }
    
    @ViewBuilder
    private func mainBody() -> some View {
        HStack {
            RegisteredDeviceView(device: device, connectionState: state)
            NavigationLink(
                destination: DeviceDetails(device: device),
                tag: device.id,
                selection: selection,
                label: {EmptyView()})
                .disabled(true)
        }
    }
}

struct RegisteredDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(DeviceData.DeviceWrapper.State.allCases, id: \.self) { state in
                RegisteredDeviceRow(device: .mock, state: state, selection: .constant(nil))
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
