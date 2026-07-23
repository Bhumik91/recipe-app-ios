//
//  UIImageView+ImageLoading.swift
//  RecipeApp
//

import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func insert(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

// Associated storage so a reused image view (table/collection cell) knows which URL it's
// currently waiting on, and can cancel a still-running download from an earlier request.
private enum AssociatedKeys {
    static let currentURL = malloc(1)!
    static let currentTask = malloc(1)!
}

extension UIImageView {
    private var currentLoadURL: String? {
        get { objc_getAssociatedObject(self, AssociatedKeys.currentURL) as? String }
        set { objc_setAssociatedObject(self, AssociatedKeys.currentURL, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var currentLoadTask: URLSessionDataTask? {
        get { objc_getAssociatedObject(self, AssociatedKeys.currentTask) as? URLSessionDataTask }
        set { objc_setAssociatedObject(self, AssociatedKeys.currentTask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        // Cancel whatever this image view was previously waiting on — otherwise a slow
        // download from a recycled cell's old recipe can land after reuse and overwrite
        // the new one (flash-of-wrong-image while scrolling).
        currentLoadTask?.cancel()
        currentLoadTask = nil
        currentLoadURL = urlString

        image = placeholder
        removeActivityIndicator()

        guard let urlString, let url = URL(string: urlString) else { return }

        if let cachedImage = ImageCache.shared.image(for: urlString) {
            image = cachedImage
            return
        }

        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        activityIndicator.startAnimating()

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                // This image view has since moved on to another request — drop this result.
                guard self.currentLoadURL == urlString else { return }

                if let data, let downloadedImage = UIImage(data: data) {
                    ImageCache.shared.insert(downloadedImage, for: urlString)
                    self.image = downloadedImage
                }
                self.removeActivityIndicator()
                self.currentLoadTask = nil
            }
        }
        currentLoadTask = task
        task.resume()
    }

    private func removeActivityIndicator() {
        subviews.forEach { view in
            if view is UIActivityIndicatorView {
                view.removeFromSuperview()
            }
        }
    }
}
