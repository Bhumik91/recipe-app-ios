//
//  LeftAlignedFlowLayout.swift
//  RecipeApp
//

import UIKit

/// A `UICollectionViewFlowLayout` that left-aligns cells within each row instead of
/// justifying them, so variable-width chips wrap like Android's `ChipGroup`.
final class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect)?.compactMap({
            $0.copy() as? UICollectionViewLayoutAttributes
        }) else { return nil }

        var leftMargin = sectionInset.left
        var lastY: CGFloat = -1

        for attribute in attributes where attribute.representedElementCategory == .cell {
            if abs(attribute.frame.origin.y - lastY) > 1 {
                leftMargin = sectionInset.left
            }
            attribute.frame.origin.x = leftMargin
            leftMargin += attribute.frame.width + minimumInteritemSpacing
            lastY = attribute.frame.origin.y
        }

        return attributes
    }
}
