//
//  ReusableProgressView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 19/8/21.
//

import SwiftUI
import Combine

// MARK: - ReusableProgressView

struct ReusableProgressView: View {
    
    var progress: Binding<Double>
    var isIndeterminate: Binding<Bool>
    
    var statusText: Binding<String>
    @State var statusColor = Color.red
    
    @State var buttonText = "Button"
    @State var buttonEnabled = true
    
    let buttonAction: () -> ()
    
    var body: some View {
        VStack {
            #if os(OSX)
            NSProgressView(value: progress.wrappedValue, maxValue: 100.0,
                           isIndeterminate: isIndeterminate.wrappedValue)
                .padding(.horizontal)
            #else
            ProgressView(value: progress.wrappedValue, total: 100.0)
                .padding(.horizontal)
            #endif
            
            HStack {
                ConnectionStatus(color: statusColor)
                Text(statusText.wrappedValue.uppercasingFirst)
                    .lineLimit(1)
            }
            
            Button(buttonText, action: buttonAction)
                .centerTextInsideForm()
//                .disabled(!buttonEnabled)
        }
        .padding(.vertical)
        .frame(height: 120)
    }
}

// MARK: - Preview

#if DEBUG
//struct ReusableProgressView_Previews: PreviewProvider {
//    
//    static var noOp: () -> () = { }
//    
//    static var previews: some View {
//        ReusableProgressView(buttonAction: noOp)
//    }
//}
#endif
