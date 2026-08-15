//
//  UIView+ImageCardStyle.swift
//  RecipeApp
//

import UIKit

extension UIView {
    /// Rounds a hero/thumbnail image (or its wrapper card) and optionally attaches a
    /// bottom-to-top gradient overlay for legible text over the image. Callers that
    /// request a gradient own the returned layer and must keep its frame in sync with
    /// `bounds` (e.g. in `layoutSubviews` / `viewDidLayoutSubviews`).
    @discardableResult
    func applyImageCardStyle(
        cornerRadius: CGFloat,
        addsGradientOverlay: Bool = false,
        gradientColors: [UIColor] = [.clear, .black],
        gradientLocations: [NSNumber] = [0.4, 1.0]
    ) -> CAGradientLayer? {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true

        guard addsGradientOverlay else { return nil }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.locations = gradientLocations
        layer.addSublayer(gradientLayer)
        return gradientLayer
    }
}
