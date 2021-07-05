//
//  RenameDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/7/21.
//

import SwiftUI
import Combine

// MARK: - RenameDeviceView

struct RenameDeviceView: View {
    
    @EnvironmentObject var appData: AppData
    
    // MARK: Properties
    
    @State private var presentedDevice: Binding<RegisteredDevice?>
    @State private var newDeviceName: String
    @State private var requestIsOngoing = false
    
    @State private var cancellables: Set<AnyCancellable>
    
    // MARK: Init
    
    init(_ presentedDevice: Binding<RegisteredDevice?>) {
        self.presentedDevice = presentedDevice
        self.newDeviceName = presentedDevice.wrappedValue?.name ?? ""
        self.cancellables = Set<AnyCancellable>()
    }
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Rename Device")
                .font(.headline)
            
            if requestIsOngoing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                TextField("", text: $newDeviceName)
                    .modifier(FixPlaceholder(for: $newDeviceName, text: "New Device Name"))
                    .disableAllAutocorrections()
                    .foregroundColor(.accentColor)
                    .modifier(RoundedTextFieldShape(.lightGrey))
                    .padding()
            }
            
            Button("OK") {
                attemptRename()
            }
        }
        .padding()
    }
}

// MARK: - Private

fileprivate extension RenameDeviceView {
    
    func attemptRename() {
        guard let device = presentedDevice.wrappedValue,
              let currentProject = appData.selectedProject,
              let apiKey = appData.projectDevelopmentKeys[currentProject]?.apiKey,
              let renameRequest = HTTPRequest.renameDevice(device.id, as: newDeviceName,
                                                           in: currentProject, using: apiKey) else { return }
        
        requestIsOngoing = true
        Network.shared.perform(renameRequest, responseType: RenameDeviceResponse.self)
            .sink(receiveCompletion: { completion in
                self.presentedDevice.wrappedValue = nil
            }, receiveValue: { response in
                self.presentedDevice.wrappedValue = nil
            })
            .store(in: &cancellables)
    }
}

// MARK: - Preview

#if DEBUG
struct RenameDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RenameDeviceView(.constant(RegisteredDevice.mock))
        }
        .previewLayout(.sizeThatFits)
        .environmentObject(Preview.mockScannerData)
    }
}
#endif
