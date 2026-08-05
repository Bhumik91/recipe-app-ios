//
//  UIView+CornerRadius.swift
//  RecipeApp
//

import UIKit

extension UIView {
    /// Rounds all four corners to the given radius, clipping this view's own content
    /// (e.g. an image) to match. Pair with `applyShadow` on a non-clipping ancestor view
    /// if a shadow is also needed, since `masksToBounds` would clip it away here.
    func roundCorners(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
