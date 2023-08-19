//
//  ImageLoader.swift
//  CombineDemo
//
//  Created by Manish Rathi on 19/08/2023.
//

import UIKit
import Combine

protocol ImageLoading: AnyObject {
    var imageLoadingPublisher: Published<UIImage?>.Publisher { get }

    func loadImage(_ imageURL: URL)
    func cancelImageLoading()
}

class ImageLoader {
    @Published var downloadedImage: UIImage?
    var cancellable: AnyCancellable?

    lazy var urlSession = URLSession.shared
    lazy var backgroundQueue = DispatchQueue.global()
    lazy var mainQueue = DispatchQueue.main
}

extension ImageLoader: ImageLoading {
    var imageLoadingPublisher: Published<UIImage?>.Publisher { $downloadedImage }

    func loadImage(_ imageURL: URL) {
        cancellable = urlSession
            .dataTaskPublisher(for: imageURL)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .sink { [weak self] in self?.downloadedImage = $0 }
    }

    func cancelImageLoading() {
        cancellable?.cancel()
    }
}
