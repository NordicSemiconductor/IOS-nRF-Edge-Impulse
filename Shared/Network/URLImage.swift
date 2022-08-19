//
//  URLImage.swift
//  nRF-Edge-Impulse
//
//  Created by Dinesh Harjani on 5/4/21.
//

import SwiftUI
import Combine
import iOS_Common_Libraries

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
        (loader.image ?? placeholderImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onAppear() {
                loader.load()
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
        cancellable?.cancel()
    }
    
    // MARK: - API
    
    func load() {
        cancellable = Network.shared.downloadImage(for: url)
            .assign(to: \.image, on: self)
    }
}

// MARK: - Preview

#if DEBUG
struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            URLImage(url: URL(string: "https://avatarfiles.alphacoders.com/169/169651.jpg")!,
                     placeholderImage: Image("EdgeImpulse"))
                .frame(width: 200, height: 200)
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
