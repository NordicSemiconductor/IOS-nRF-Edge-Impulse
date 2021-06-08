//
//  DataAquisitionView+Logic.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 8/6/21.
//

import Foundation

internal extension DataAcquisitionView {

    func startSampling() {
        viewState.progressString = "Requesting Sample ID..."
        appData.requestNewSampleID(viewState) { response, error in
            guard let response = response else {
                let error: Error! = error
                viewState.isSampling = false
                viewState.progressString = error.localizedDescription
                return
            }
        
            viewState.progressString = "Obtained Sample ID."
            scannerData.startSampling(viewState)
        }
    }
}
