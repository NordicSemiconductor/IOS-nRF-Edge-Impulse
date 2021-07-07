//
//  DeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 02/07/2021.
//

import SwiftUI

struct DeviceDetails: View {
    @EnvironmentObject var deviceData: DeviceData
    
    let device: RegisteredDevice
    
    var body: some View {
            Form {
                DeviceInfoRow(title: "Created At:", systemImage: "calendar", content: device.created.toDate()?.formatterString() ?? "")
                DeviceInfoRow(title: "Last Seen:", systemImage: "eye", content: device.lastSeen.toDate()?.formatterString() ?? "")
                DeviceInfoRow(title: "Device ID:", systemImage: "person", content: device.deviceId)
                DeviceInfoRow(title: "Device Type:", systemImage: "t.square", content: device.deviceType)
                
                BoolDeviceInfoRow(title: "Remote Management Connected", systemImage: "app.connected.to.app.below.fill", choice: device.remoteMgmtConnected)
                BoolDeviceInfoRow(title: "Supports Snapshot Streaming", systemImage: "arrow.left.and.right", choice: device.supportsSnapshotStreaming)
                
                Section(header: Text("Sensors")) {
                    ForEach(device.sensors) { SensorSection(sensor: $0) }
                }
                
                if let state = deviceData.connectionState(of: device) {
                    connectionSection(state: state)
                }
            }
            .accentColor(Assets.blue.color)
            .navigationTitle(Text(device.name))
    }
    
    // MARK: Connection section
    @ViewBuilder
    private func connectionSection(state: DeviceData.RegisteredDeviceWrapper.State) -> some View {
        
        let footerText = state == .notConnectable ? "The device can't be connected" : ""
        
        Section(header: Text("Connection"), footer: Text(footerText)) {
            if case .readyToConnect = state {
                Button("Connect") {
                    deviceData.tryToConnect(registeredDevice: device)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else if case .connecting = state {
                HStack {
                    Button("Connect") { }
                    .disabled(true)
                    ProgressView()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
            } else if case .connected = state {
                Button("Disconnect") {
                    deviceData.disconnect(registeredDevice: device)
                }
                .foregroundColor(Assets.red.color)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        
    }
}

private struct DeviceInfoRow: View {
    @EnvironmentObject private var hudState: HUDState
    
    let title: String
    let systemImage: String?
    let content: String
        
    var body: some View {
        HStack {
            Label(title, systemImage: systemImage ?? "")
            Spacer()
            
            Text(content)
                .bold()
                .onLongPressGesture {
                    UIPasteboard.general.string = content
                    hudState.show(title: "Copied", systemImage: "doc.on.doc")
                }
        }
    }
}

private struct BoolDeviceInfoRow: View {
    let title: String
    let systemImage: String?
    let choice: Bool
    
    var body: some View {
        HStack {
            Label(title, systemImage: systemImage ?? "")
            Spacer()
            choice
            ? Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            : Image(systemName: "xmark.circle.fill").foregroundColor(Assets.red.color)
        }
    }
}

private struct SensorSection: View {
    let sensor: Sensor

    var body: some View {
        Label(
            title: { Text(sensor.name).font(.headline) },
            icon: { sensorIcon(sensorName: sensor.name) }
        )
        
        sensor.maxSampleLengthS.map { l in
            HStack {
                Label("Max. Sample Length:", systemImage: "")
                Spacer()
                Text("\(l)").bold()
            }
        }
        
        if sensor.frequencies?.hasItems == true {
            let fs = sensor.frequencies!
                .map { String(format: "%g", $0) }
                .joined(separator: ", ")
            
            HStack(alignment: .top) {
                Label("Frequencies:", systemImage: "")
                Spacer()
                Text(fs).bold()
            }
        }
    }
    
    private func sensorIcon(sensorName: String) -> Image {
        switch sensorName {
        case "Camera":
            return Image(systemName: "camera")
        case "Microphone":
            return Image(systemName: "mic")
        case "Accelerometer":
            return Image(systemName: "move.3d")
        default:
            return Image(systemName: "square")
        }
    }
}

#if DEBUG
struct DeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetails(device: .mock)
            .environmentObject(DeviceData(appData: AppData()))
    }
}
#endif
