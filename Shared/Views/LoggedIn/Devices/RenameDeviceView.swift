//
//  RenameDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/7/21.
//

import SwiftUI
import Combine
import OSLog

// MARK: - RenameDeviceView

struct RenameDeviceView: View {
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var deviceData: DeviceData
    
    // MARK: Properties
    
    var presentedDevice: Binding<Device?>
    @State private var newDeviceName: String
    @State private var viewState: ViewState
    
    @State private var cancellables: Set<AnyCancellable>
    
    // MARK: Init
    
    init(_ presentedDevice: Binding<Device?>, oldName: String,
         viewState: ViewState = .waitingForInput) {
        self.presentedDevice = presentedDevice
        self.viewState = viewState
        self.newDeviceName = oldName
        self.cancellables = Set<AnyCancellable>()
    }
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Rename Device")
                .font(.headline)
            
            switch viewState {
            case .requestIsOngoing:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            case .success:
                Text("Success!")
                    .foregroundColor(.green)
                    .padding(4)
            default:
                TextField("", text: $newDeviceName)
                    .modifier(FixPlaceholder(for: $newDeviceName, text: "New Device Name"))
                    .disableAllAutocorrections()
                    .accentColor(.black)
                    .modifier(RoundedTextFieldShape(.lightGrey))
                    .disabled(!textFieldEnabled)
                    .padding(4)
                    .introspectTextField { textField in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            textField.becomeFirstResponder()
                            #if os(iOS)
                            textField.selectAll(nil)
                            #endif
                        }
                    }
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(Assets.red.color)
                    .padding(4)
            }
            
            HStack(spacing: 8) {
                Button("OK", action: okButton)
                    .foregroundColor(.primary)
                    .disabled(!buttonEnabled)
                    .keyboardShortcut(.defaultAction)
                
                switch viewState {
                case .waitingForInput:
                    Button("Cancel", action: dismiss)
                        .foregroundColor(Assets.red.color)
                        .disabled(!buttonEnabled)
                default:
                    EmptyView()
                }
            }
        }
        .padding()
        .background(Color.secondarySystemBackground)
        .frame(minWidth: 200)
    }
    
    // MARK: Logic
    
    private var textFieldEnabled: Bool {
        switch viewState {
        case .waitingForInput:
            return true
        default:
            return false
        }
    }
    
    private var buttonEnabled: Bool {
        switch viewState {
        case .requestIsOngoing:
            return false
        default:
            return true
        }
    }
    
    private var errorMessage: String? {
        switch viewState {
        case .error(let error):
            return error.localizedDescription
        default:
            return nil
        }
    }
}

// MARK: - Private

internal extension RenameDeviceView {
    
    enum ViewState {
        case waitingForInput
        case requestIsOngoing
        case error(_ error: Error)
        case success
    }
}

fileprivate extension RenameDeviceView {
    
    func okButton() {
        switch viewState {
        case .waitingForInput:
            attemptRename()
        case .requestIsOngoing:
            break
        case .error(_), .success:
            dismiss()
        }
    }
    
    func dismiss() {
        presentedDevice.wrappedValue = nil
    }
    
    func attemptRename() {
        let logger = Logger(category: String(describing: RenameDeviceView.self))
        guard let device = presentedDevice.wrappedValue,
              let currentProject = appData.selectedProject,
              let apiKey = appData.apiToken,
              let renameRequest = HTTPRequest.renameDevice(device, as: newDeviceName,
                                                           in: currentProject, using: apiKey) else { return }
        
        viewState = .requestIsOngoing
        Network.shared.perform(renameRequest, responseType: RenameDeviceResponse.self)
            .sinkReceivingError(onError: { error in
                self.viewState = .error(error)
                logger.debug("Request Response failed with Error: \(error.localizedDescription).")
            }, receiveValue: { _ in
                self.viewState = .success
                logger.debug("Request Response Successful. Refreshing list of Devices.")
                self.deviceData.refresh()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    self.okButton()
                }
            })
            .store(in: &cancellables)
    }
}

// MARK: - Preview

#if DEBUG
struct RenameDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RenameDeviceView(.constant(Device.mock), oldName: Device.mock.deviceId)
            RenameDeviceView(.constant(Device.mock), oldName: Device.mock.deviceId, viewState: .requestIsOngoing)
            RenameDeviceView(.constant(Device.mock), oldName: Device.mock.deviceId, viewState: .error(NordicError.init(description: "A")))
            RenameDeviceView(.constant(Device.mock), oldName: Device.mock.deviceId, viewState: .success)
        }
        .previewLayout(.sizeThatFits)
        .environmentObject(Preview.mockScannerData)
        .environmentObject(Preview.mockScannerData)
    }
}
#endif
