//
//  RegisteredDeviceRow.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 28/07/2021.
//

import SwiftUI

struct RegisteredDeviceRow: View {
    
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: Properties
    
    let device: Device
    let state: DeviceData.DeviceWrapper.State
    let selection: Binding<String?>
    
    private let isSelected: Bool
    
    // MARK: Init
    
    init(device: Device, state: DeviceData.DeviceWrapper.State, selection: Binding<String?>) {
        self.device = device
        self.state = state
        self.selection = selection
        self.isSelected = device.deviceId == selection.wrappedValue
    }
    
    var body: some View {
        mainBody()
            .contentShape(Rectangle())
            .background(isSelected ? Color.universalAccentColor.opacity(0.6) : Color.clear)
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
        }
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
