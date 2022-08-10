//
//  UILinearProgressView.swift
//  nRF-Edge-Impulse (iOS)
//
//  Created by Dinesh Harjani on 25/10/21.
//

#if os(iOS)

import SwiftUI

// MARK: - UIProgressView

struct UILinearProgressView: UIViewRepresentable {
    
    @Binding var value: Double
    
    // MARK: UIViewRepresentable
    
    func makeUIView(context: Context) -> UIProgressView {
        let progressView = UIProgressView()
        progressView.progress = Float(value / 100.0)
        progressView.progressTintColor = Color.nordicBlue.uiColor
        return progressView
    }
    
    func updateUIView(_ uiView: UIProgressView, context: Context) {
        update(uiView)
    }
}

// MARK: - Private

fileprivate extension UILinearProgressView {
    
    func update(_ progressView: UIProgressView) {
        progressView.progress = Float(value / 100.0)
    }
}

#endif
