//
//  Collection+SafeSubscript.swift
//  RecipeApp
//

import Foundation

extension Collection {
    /// Returns the element at `index`, or nil when it is out of bounds.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
