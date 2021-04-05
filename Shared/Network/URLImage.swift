//
//  URLImage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 5/4/21.
//

import SwiftUI
import Combine

struct URLImage: View {
    
    let placeholderImage: Image
    @StateObject private var loader: URLImageLoader
    
    // MARK: - Init
    
    init(url: URL, placeholderImage: Image) {
        self.placeholderImage = placeholderImage
        _loader = StateObject(wrappedValue: URLImageLoader(url: url))
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let loadedImage = loader.image {
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                placeholderImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onAppear() {
                        loader.load()
                    }
            }
        }
    }
}

// MARK: - URLImageLoader

final class URLImageLoader: ObservableObject {
    
    // MARK: - Properties
    
    @Published var image: Image?
    
    // MARK: - Private Properties
    
    private let url: URL
    private var cancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(url: URL) {
        self.url = url
    }
    
    deinit {
        cancel()
    }
    
    // MARK: - API
    
    func load() {
        cancellable = Network.shared.downloadImage(for: url)
            .assign(to: \.image, on: self)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

// MARK: - Preview

#if DEBUG
struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            URLImage(url: URL(string: "https://avatarfiles.alphacoders.com/169/169651.jpg")!,
                     placeholderImage: Image("EdgeImpulse"))
        }
    }
}
#endif
