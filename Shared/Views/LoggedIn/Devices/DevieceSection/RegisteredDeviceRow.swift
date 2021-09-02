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
    
    private let deviceWrapper: DeviceData.DeviceWrapper
    
    private var device: Device { deviceWrapper.device}
    private var state: DeviceData.DeviceWrapper.State { deviceWrapper.state }
    let selection: Binding<String?>
    
    private let isSelected: Bool
    
    // MARK: Init
    
    init(_ deviceWrapper: DeviceData.DeviceWrapper, selection: Binding<String?>) {
        self.deviceWrapper = deviceWrapper
        self.selection = selection
        self.isSelected = deviceWrapper.device.deviceId == selection.wrappedValue
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
                RegisteredDeviceRow(DeviceData.DeviceWrapper(device: .connectableMock), selection: .constant(nil))
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
