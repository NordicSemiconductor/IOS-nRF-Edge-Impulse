//
//  DeviceStatusSectionView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 9/9/21.
//

import SwiftUI

struct DeviceStatusSectionView: View {
    
    @EnvironmentObject var deviceData: DeviceData
    
    let device: Device
    let state: DeviceData.DeviceWrapper.State
    
    var body: some View {
        Section(header: Text("Status")) {
            HStack {
                switch state {
                case .notConnectable:
                    NordicLabel(title: "The device can't be connected", systemImage: "bolt.horizontal")
                        .foregroundColor(Color.disabledTextColor)
                case .readyToConnect:
                    NordicLabel(title: "Ready to Connect", systemImage: "network")
                    Spacer()
                    ConnectionStatus(color: Assets.blue.color)
                case .connecting:
                    NordicLabel(title: "Connecting...", systemImage: "network")
                    Spacer()
                    ConnectionStatus(color: .yellow)
                    ProgressView()
                        .padding(.leading)
                case .connected:
                    NordicLabel(title: "Connected", systemImage: "personalhotspot")
                    Spacer()
                    ConnectionStatus(color: .green)
                case .deleting:
                    NordicLabel(title: "Performing Deletion...", systemImage: "network")
                    Spacer()
                    ConnectionStatus(color: .red)
                }
            }
            .padding(.trailing, 4)
            
            switch state {
            case .readyToConnect:
                Button("Connect") {
                    deviceData.tryToConnect(device: device)
                }
                .foregroundColor(.positiveActionButtonColor)
                .frame(maxWidth: .infinity, alignment: .center)
            case .connecting:
                Button("Connect") { }
                    .disabled(true)
                .frame(maxWidth: .infinity, alignment: .center)
            case .connected:
                Button("Disconnect") {
                    deviceData.disconnect(device: device)
                }
                .foregroundColor(.negativeActionButtonColor)
                .frame(maxWidth: .infinity, alignment: .center)
            default:
                EmptyView()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DDeviceStatusSectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            List {
                ForEach(DeviceData.DeviceWrapper.State.allCases, id: \.self) { state in
                    DeviceStatusSectionView(device: .connectableMock, state: state)
                }
            }
            .environmentObject(DeviceData(appData: AppData()))
            .previewLayout(.sizeThatFits)
        }
        
    }
}
#endif
