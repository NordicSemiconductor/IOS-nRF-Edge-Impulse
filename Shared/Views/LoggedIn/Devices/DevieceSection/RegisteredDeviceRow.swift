//
//  RegisteredDeviceRow.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 28/07/2021.
//

import SwiftUI

struct RegisteredDeviceRow: View {
    @EnvironmentObject var deviceData: DeviceData
    
    let device: Device
    let state: DeviceData.DeviceWrapper.State
    let selection: Binding<String?>
    
    var body: some View {
        mainBody()
            .contentShape(Rectangle())
            .onTapGesture {
                if state == .notConnectable || state == .connected {
                    selection.wrappedValue = device.deviceId
                } else if state == .readyToConnect {
                    deviceData.tryToConnect(device: device)
                }
            }
    }
    
    @ViewBuilder
    private func mainBody() -> some View {
        HStack {
            RegisteredDeviceView(device: device, connectionState: state)
            Image(systemName: "chevron.right")
                .renderingMode(.template)
                .foregroundColor(.gray)
            NavigationLink(
                destination: DeviceDetails(device: device),
                tag: device.deviceId,
                selection: selection,
                label: {EmptyView()})
                .frame(width: 0)
                .disabled(true)
        }
        .padding()
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
