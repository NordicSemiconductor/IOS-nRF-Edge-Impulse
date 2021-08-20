//
//  DeviceDetails.swift
//  nRF-Edge-Impulse
//
//  Created by Nick Kibysh on 02/07/2021.
//

import SwiftUI

struct DeviceDetails: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var deviceData: DeviceData
    @State private var showingAlert = false
    
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
                
                deleteSection()
            }
            .accentColor(.primary)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Delete Device"),
                      message: Text("Are you sure you want to delete this Device?"),
                      primaryButton: .destructive(Text("Yes"), action: confirmDeleteDevice),
                      secondaryButton: .default(Text("Cancel"), action: dismissDeleteDevice))
            }
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
    
    @ViewBuilder
    private func deleteSection() -> some View {
        Section(footer: Text("Delete this device from the list of registered devices")) {
            Button("Delete") {
                showingAlert = true
            }
            .foregroundColor(Assets.red.color)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

private extension DeviceDetails {
    func confirmDeleteDevice() {
        showingAlert = false
        deviceData.tryToDelete(device: device)
        presentationMode.wrappedValue.dismiss()
    }
    
    func dismissDeleteDevice() {
        showingAlert = false
    }
}

private struct DeviceInfoRow: View {
    @EnvironmentObject private var hudState: HUDState
    
    let title: String
    let systemImage: String?
    let content: String
    
    var body: some View {
        HStack {
            NordicLabel(title: title, systemImage: systemImage ?? "")
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
                .foregroundColor(.secondary)
        }
    }
}

private struct BoolDeviceInfoRow: View {
    let title: String
    let systemImage: String?
    let choice: Bool
    
    var body: some View {
        HStack {
            Label(
                title: { Text(title) },
                icon: {
                    Image(systemName: systemImage ?? "")
                        .renderingMode(.template)
                        .foregroundColor(.universalAccentColor)
                }
            )
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
                    NordicLabel(title: "Max. Sample Length:", systemImage: "waveform.path.ecg")
                    Spacer()
                    Text("\(length) ms").bold()
                        .foregroundColor(.secondary)
                }
            }
            
            if let frequencies = sensor.frequencies, frequencies.hasItems == true {
                let text = ListFormatter.localizedString(
                    byJoining: frequencies.map { "\(String(format: "%.2f", $0)) Hz" })
                
                HStack(alignment: .top) {
                    NordicLabel(title: "Frequencies", systemImage: "wave.3.right")
                    Spacer()
                    Text(text).bold()
                        .foregroundColor(.secondary)
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
            return "gyroscope"
        case "Magnetometer":
            return "tuningfork"
        default:
            return "square"
        }
    }
}

private struct NordicLabel: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        Label(
            title: { Text(title) },
            icon: {
                Image(systemName: systemImage)
                    .renderingMode(.template)
                    .foregroundColor(.universalAccentColor)
            }
        )
    }
}

#if DEBUG
struct DeviceDetails_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DeviceDetails(device: .mock)
                .navigationTitle("Device")
                .environmentObject(DeviceData(appData: AppData()))
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
                .previewDisplayName("iPhone 12 Pro Max")
            
            DeviceDetails(device: .mock)
                .navigationTitle("Device")
                .environmentObject(DeviceData(appData: AppData()))
                .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
                .preferredColorScheme(.dark)
                .previewDisplayName("iPhone 12")
            
            DeviceDetails(device: .mock)
                .navigationTitle("Device")
                .environmentObject(DeviceData(appData: AppData()))
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 mini"))
                .previewDisplayName("iPhone 12 min")
        }
    }
}
#endif
