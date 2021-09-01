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
                selection.wrappedValue = device.deviceId
            }
    }
    
    @ViewBuilder
    private func mainBody() -> some View {
        HStack {
            RegisteredDeviceView(device: device, connectionState: state)
            #if os(iOS)
            NavigationLink(
                destination: EmptyView(),
                tag: 1,
                selection: .constant(2),
                label: {
                    EmptyView()
                })
                .hidden()
                .disabled(true)
                .frame(width: 0.1)
            #endif
            
            NavigationLink(
                destination: DeviceDetails(device: device),
                tag: device.deviceId,
                selection: selection,
                label: {EmptyView()})
                .frame(width: 0.1)
                .disabled(true)
                .hidden()
            
            Image(systemName: "chevron.right")
                .renderingMode(.template)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }
}

#if DEBUG
struct RegisteredDeviceRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(DeviceData.DeviceWrapper.State.allCases, id: \.self) { state in
                RegisteredDeviceRow(device: .connectableMock, state: state, selection: .constant(nil))
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
