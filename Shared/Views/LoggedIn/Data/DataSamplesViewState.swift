//
//  DataSamplesViewState.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 4/5/21.
//

import Foundation
import Combine

final class DataSamplesViewState: ObservableObject {
    
    @Published var selectedCategory: DataSample.Category = .training
    @Published var samples = [DataSample]()
}
