//
//  SignalParameters.swift
//  Landmarks
//
//  Created by Nick Kibysh on 23/03/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftUI

/// `SignalDisplayParameters` defines parameters for displaying `SignalLevel`
struct SignalDisplayParameters {
    let numberOfBars: Int
    let numberOfFilledBars: Int
    
    let x0: Double
    let x1: Double
    let foo: (Double) -> Double
    
    private var y: [Double] {
        (0..<numberOfBars).map {
            foo( ((x1 - x0) / Double(numberOfBars)) * Double($0) + x0 )
        }
    }
    
    // spacing = barWidth * spacingMultiplier
    var spacingMultiplier: CGFloat
    
    var color: Color
    
    /**
     Init
    - Parameters:
        - numberOfBars: Number of bars
        - numberOfFilledBars: Number of filled bars: If `numberOfFilledBars < numberOfBars` it will be equal to `numberOfFilledBars == numberOfBars`
        - spacingMultiplier: Defines spacing between bars relates to bar width.
            - Example:
                `spacerWidth = barWidth * spacingMultiplier`
                `spacingMultiplier = 1` => spacerWidth == barWidth
        - x0: begining of slice on which `foo` will be applied
        - x1: end of slice on which `foo` will be applied
        - color: Bars' color
        - foo: Defines how bars' height change.
            Example:
                f(y) = x " 2 => bars' height increas in quadratic way
                f(y) = x => Liniar
     */
    init(numberOfBars: Int = 3,
         numberOfFilledBars: Int = 2,
         x0: Double = 0.6,
         x1: Double = 2,
         spacingMultiplier: CGFloat = 0.3,
         color: Color = .primary,
         foo: @escaping (Double) -> Double = { $0 * $0 }) {
        self.numberOfBars = numberOfBars
        self.numberOfFilledBars = min(numberOfFilledBars, numberOfBars)
        
        self.x0 = x0
        self.x1 = x1
        self.spacingMultiplier = spacingMultiplier
        
        self.color = color
        
        self.foo = foo
    }
    
    func defineBars(basedOn size: CGSize) -> [CGRect] {
        let nBars = CGFloat(numberOfBars)
        let barWidth = size.width / (nBars + spacingMultiplier * nBars - spacingMultiplier)
        let spacerWidth = barWidth * spacingMultiplier
        
        let barHeights = y.map { size.height * CGFloat($0 / (y.max() ?? 8)) }
        let xPositions = (0..<numberOfBars).map { CGFloat($0) * (barWidth + spacerWidth) }
        
        return zip(xPositions, barHeights).map { CGRect(x: $0.0, y: size.height - $0.1, width: barWidth, height: $0.1) }
    }
}

extension SignalDisplayParameters {
    init(rssi: RSSI) {
        
        let color: Color
        let numberOfFilledBars: Int
        
        switch rssi {
        case .good:
            color = .green
            numberOfFilledBars = 3
        case .ok:
            color = .yellow
            numberOfFilledBars = 2
        case .bad:
            color = .orange
            numberOfFilledBars = 1
        case .outOfRange:
            color = .primary
            numberOfFilledBars = 0
        case .practicalWorst:
            color = .red
            numberOfFilledBars = 0
        }
        
        self.init(numberOfBars: 3, numberOfFilledBars: numberOfFilledBars, color: color)
    }
}
