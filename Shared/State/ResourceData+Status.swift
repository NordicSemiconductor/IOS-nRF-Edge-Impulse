//
//  ResourceData+Status.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 21/4/21.
//

import SwiftUI

extension ResourceData {
    
    enum Status: String {
        case notAvailable
        case available
        case loading
        case upToDate
        
        var string: String {
            switch self {
            case .notAvailable:
                return "Not Available"
            case .available:
                return "Available"
            case .loading:
                return "Loading"
            case .upToDate:
                return "Up to Date"
            }
        }
        
        var systemImageName: String {
            switch self {
            case .notAvailable:
                return "xmark.octagon.fill"
            case .available:
                return "checkmark.cicle.fill"
            case .loading:
                return "clock.fill"
            case .upToDate:
                return "checkmark.shield.fill"
            }
        }
        
        var systemImageColor: Color {
            switch self {
            case .notAvailable:
                return Assets.red.color
            case .available:
                return Assets.sun.color
            case .loading:
                return Assets.lightGrey.color
            case .upToDate:
                return Color.green
            }
        }
        
        @ViewBuilder
        func label() -> some View {
            HStack {
                Text(string)
                Image(systemName: systemImageName)
                    .frame(size: .SmallImageSize)
                    .foregroundColor(systemImageColor)
            }
        }
    }
}
