//
//  NotificationFilterTab.swift
//  RecipeApp
//

import Foundation

/// The All / Saved / Removed filter above the notification log.
/// Raw values are the segment indices `SegmentedSelectorView` reports.
enum NotificationFilterTab: Int, CaseIterable {
    case all = 0
    case saved = 1
    case removed = 2

    var title: String {
        switch self {
        case .all: return "All"
        case .saved: return "Saved"
        case .removed: return "Removed"
        }
    }

    /// Empty-state copy for this filter.
    var emptyMessage: String {
        switch self {
        case .all: return "Your recipe actions will appear here"
        case .saved: return "Recipes you save will appear here"
        case .removed: return "Recipes you remove will appear here"
        }
    }
}
