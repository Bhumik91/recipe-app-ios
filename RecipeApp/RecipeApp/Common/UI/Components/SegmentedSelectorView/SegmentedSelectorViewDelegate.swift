//
//  SegmentedSelectorViewDelegate.swift
//  RecipeApp
//

import Foundation

protocol SegmentedSelectorViewDelegate: AnyObject {
    func segmentedSelectorView(_ view: SegmentedSelectorView, didSelect index: Int)
}
