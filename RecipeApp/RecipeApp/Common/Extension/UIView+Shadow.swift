//
//  UIView+Shadow.swift
//  RecipeApp
//

import UIKit

extension UIView {
    /// Soft drop shadow shared by floating buttons, cards, and the share popup.
    func applyShadow(
        color: UIColor = .black,
        opacity: Float = 0.08,
        radius: CGFloat = 10,
        offset: CGSize = CGSize(width: 0, height: 4)
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
}
