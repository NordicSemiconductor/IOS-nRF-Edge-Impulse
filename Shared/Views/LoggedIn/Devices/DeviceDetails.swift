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
        List {
            Text(device.name)
                .font(.headline)
            
            DeviceInfoRow(title: "Created At:", systemImage: "calendar", content: device.created.toDate()?.formatterString() ?? "")
            DeviceInfoRow(title: "Last Seen:", systemImage: "eye", content: device.lastSeen.toDate()?.formatterString() ?? "")
            DeviceInfoRow(title: "Device ID:", systemImage: "person", content: device.deviceId)
            DeviceInfoRow(title: "Device Type:", systemImage: nil, content: device.deviceType)
            
            Section(header: Text("Sensors")) {
                ForEach(device.sensors) { SensorSection(sensor: $0) }
            }
        }
    }
}

private struct DeviceInfoRow: View {
    let title: String
    let systemImage: String?
    let content: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: systemImage ?? "")
            Spacer()
            Text(content).bold()
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
    }
}
#endif
