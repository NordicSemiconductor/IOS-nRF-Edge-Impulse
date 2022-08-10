//
//  ErrorView.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 16/3/21.
//

import SwiftUI

struct ErrorView: View {
    
    let error: Error
    
    private var errorMessage: String {
        var errorMessage: String!
        if let decodingError = error as? DecodingError {
            errorMessage = decodingError.recoverySuggestion
        }
        
        if errorMessage == nil {
            errorMessage = error.localizedDescription
        }
        return errorMessage
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "xmark.octagon.fill")
                .resizable()
                .frame(size: .StandardImageSize)
                .foregroundColor(.nordicRed)
            Text("\(errorMessage)")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(error: NordicError.testError)
    }
}
