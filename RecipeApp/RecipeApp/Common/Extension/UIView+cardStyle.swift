//
//  UIView+CardStyle.swift
//  RecipeApp
//

import UIKit

extension UIView {
    /// Card decoration shared by list/table cell containers: fill, rounded corners, hairline stroke, soft shadow.
    func applyCardStyle() {
        backgroundColor = UIColor(resource: .brandWhite)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(resource: .brandGray4).cgColor
        applyShadow(opacity: 0.05, radius: 4, offset: CGSize(width: 0, height: 2))
    }
}
