//
//  UIView+Circular.swift
//  RecipeApp
//

import UIKit

extension UIView {
    /// Rounds this view into a circle using half its current bounds height. Leaves
    /// `masksToBounds` untouched so a shadow applied via `applyShadow` still renders outside it.
    func makeCircular() {
        self.layer.cornerRadius = self.bounds.height / 2
    }
}
