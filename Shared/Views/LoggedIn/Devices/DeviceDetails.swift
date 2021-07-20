//
//  DeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 02/07/2021.
//

import SwiftUI

struct DeviceDetails: View {
    @EnvironmentObject var deviceData: DeviceData
    
    let device: Device
    
    var body: some View {
            FormIniOSListInMacOS {
                Section(header: Text("Device Information")) {
                    DeviceInfoRow(title: "ID:", systemImage: "person", content: device.deviceId)
                    DeviceInfoRow(title: "Type:", systemImage: "t.square", content: device.deviceType)
                    DeviceInfoRow(title: "Created At:", systemImage: "calendar", content: device.created.toDate()?.formatterString() ?? "")
                    DeviceInfoRow(title: "Last Seen:", systemImage: "eye", content: device.lastSeen.toDate()?.formatterString() ?? "")
                }
                
                Section(header: Text("Status")) {
                    BoolDeviceInfoRow(title: "Connected to Remote Management", systemImage: "network", choice: device.remoteMgmtConnected)
                    BoolDeviceInfoRow(title: "Supports Snapshot Streaming", systemImage: "arrow.left.and.right", choice: device.supportsSnapshotStreaming)
                }
                
                ForEach(device.sensors) {
                    SensorSection(sensor: $0)
                }
                
                if let state = deviceData.connectionState(of: device) {
                    connectionSection(state: state)
                }
            }
            .accentColor(.primary)
            .navigationTitle(Text(device.name))
            .toolbar {
                if let state = deviceData.connectionState(of: device) {
                    if case .readyToConnect = state {
                        Button("Connect") {
                            deviceData.tryToConnect(device: device)
                        }
                    } else if case .connecting = state {
                        ProgressView()
                        
                    } else if case .connected = state {
                        Button("Disconnect") {
                            deviceData.disconnect(device: device)
                        }
                    }
                }
            }
    }
    
    // MARK: Connection section
    @ViewBuilder
    private func connectionSection(state: DeviceData.DeviceWrapper.State) -> some View {
        
        let footerText = state == .notConnectable ? "The device can't be connected" : ""
        
        Section(header: Text("Connection"), footer: Text(footerText)) {
            if case .readyToConnect = state {
                Button("Connect") {
                    deviceData.tryToConnect(device: device)
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
                    deviceData.disconnect(device: device)
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
                    #if os(iOS)
                    UIPasteboard.general.string = content
                    #elseif os(OSX)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(content, forType: .string)
                    #endif
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
        
        Section(header: Label(sensor.name, systemImage: sensorIcon)) {
            sensor.maxSampleLengthS.map { length in
                HStack {
                    Label("Max. Sample Length:", systemImage: "waveform.path.ecg")
                    Spacer()
                    Text("\(length)").bold()
                }
            }
            
            if let frequencies = sensor.frequencies, frequencies.hasItems == true {
                let text = frequencies
                    .map { String(format: "%g", $0) }
                    .joined(separator: ", ")
                
                HStack(alignment: .top) {
                    Label("Frequencies:", systemImage: "wave.3.right")
                    Spacer()
                    Text(text).bold()
                }
            }
        }
    }
    
    private var sensorIcon: String {
        switch sensor.name {
        case "Camera":
            return "camera"
        case "Microphone":
            return "mic"
        case "Accelerometer":
            return "move.3d"
        default:
            return "square"
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
