//
//  HighlightableControl.swift
//  RecipeApp
//

import UIKit

/// A `UIControl` that dims slightly while pressed, giving a plain container view the same
/// touch feedback a `UIButton` gets for free — set as a view's custom class in Interface
/// Builder to make it act like a tappable "button" while still hosting arbitrary subviews.
class HighlightableControl: UIControl {
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.6 : 1.0
            }
        }
    }
}
