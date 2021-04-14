//
//  SignalLevel.swift
//  Landmarks
//
//  Created by Nick Kibysh on 23/03/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import SwiftUI

struct SignalLevel: View {
    let rssi: RSSI
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let params = SignalDisplayParameters(rssi: rssi)
            let recs = params.defineBars(basedOn: size)
            
            let filledRects = recs[0..<params.numberOfFilledBars]
            
            Path { path in
                filledRects.forEach {
                    path.addRoundedRect(in: $0, cornerSize: CGSize(width: 4, height: 4))
                }
            }
            .fill(params.color)
            
            Path { path in
                recs.forEach {
                    path.addRoundedRect(in: $0, cornerSize: CGSize(width: 2, height: 2))
                }
            }
            .stroke(lineWidth: 1)
        }
    }
}

struct SignalLevel_Previews: PreviewProvider {
    static var previews: some View {
        SignalLevel(rssi: .good)
    }
}
