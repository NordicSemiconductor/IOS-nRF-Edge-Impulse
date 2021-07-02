//
//  RenameDeviceView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 2/7/21.
//

import SwiftUI

// MARK: - RenameDeviceView

struct RenameDeviceView: View {
    
    // MARK: Properties
    
    @State private var presentedDevice: Binding<RegisteredDevice?>
    @State private var newDeviceName: String
    
    // MARK: Init
    
    init(_ presentedDevice: Binding<RegisteredDevice?>) {
        self.presentedDevice = presentedDevice
        self.newDeviceName = presentedDevice.wrappedValue?.name ?? ""
    }
    
    // MARK: Body
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Rename Device")
                .font(.headline)
            
            TextField("", text: $newDeviceName)
                .modifier(FixPlaceholder(for: $newDeviceName, text: "New Device Name"))
                .disableAllAutocorrections()
                .foregroundColor(.accentColor)
                .modifier(RoundedTextFieldShape(.lightGrey))
                .padding()
            
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
        presentedDevice.wrappedValue = nil
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
    }
}
#endif
