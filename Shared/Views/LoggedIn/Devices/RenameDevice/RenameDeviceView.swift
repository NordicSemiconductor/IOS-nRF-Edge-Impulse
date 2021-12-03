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
    
    init(_ presentedDevice: Binding<Device?>, viewState: ViewState = .waitingForInput) {
        self.presentedDevice = presentedDevice
        self.viewState = viewState
        self.newDeviceName = ""
        self.cancellables = Set<AnyCancellable>()
    }
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Rename Device")
                .foregroundColor(.textColor)
                .font(.headline)
            
            switch viewState {
            case .requestIsOngoing:
                CircularProgressView()
                    .padding()
            case .error(let error):
                Text(error.localizedDescription)
                    .foregroundColor(Assets.red.color)
                    .padding(4)
            case .success:
                Text("Success!")
                    .foregroundColor(.green)
                    .padding(4)
            default:
                TextField("New Device Name", text: $newDeviceName)
                    .disableAllAutocorrections()
                    .foregroundColor(.textFieldColor)
                    .modifier(RoundedTextFieldShape(.lightGrey))
                    .disabled(!textFieldEnabled)
                    .frame(maxWidth: 300)
                    .padding(4)
            }
            
            RenameButtonsView(viewState, enabled: buttonEnabled, okFunction: okButton, cancelFunction: dismiss)
        }
        .padding()
        .frame(width: 350)
        .background(Color.secondarySystemBackground)
        .onAppear {
            guard let device = presentedDevice.wrappedValue else { return }
            newDeviceName = deviceData.name(for: device)
        }
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
                logger.debug("Request Response Successful. Renaming Device.")
                self.deviceData.renamed(device, to: newDeviceName)
                self.deviceData.updateRegisteredDevices()
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
            RenameDeviceView(.constant(Device.connectableMock))
            RenameDeviceView(.constant(Device.connectableMock), viewState: .requestIsOngoing)
            RenameDeviceView(.constant(Device.connectableMock), viewState: .error(NordicError.init(description: "A")))
            RenameDeviceView(.constant(Device.connectableMock), viewState: .success)
        }
        .previewLayout(.sizeThatFits)
        .environmentObject(Preview.mockScannerData)
        .environmentObject(Preview.mockScannerData)
    }
}
#endif
