//
//  SelfSizingTableView.swift
//  RecipeApp
//

import UIKit

/// A `UITableView` that reports its content size as its intrinsic content size, so it can sit
/// (non-scrolling) inside an outer `UIScrollView` and grow/shrink with its rows instead of
/// needing a height constraint the parent keeps in sync by hand.
final class SelfSizingTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            guard oldValue != contentSize else { return }
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

    // reloadData() only queues the row layout — .automaticDimension cell heights aren't measured
    // until UITableView's own next layout pass, which can land after a caller (or the outer
    // scroll view) has already read intrinsicContentSize for this cycle, leaving the table
    // rendered short. Forcing that layout pass here keeps contentSize accurate immediately.
    override func reloadData() {
        super.reloadData()
        layoutIfNeeded()
        invalidateIntrinsicContentSize()
    }
}
