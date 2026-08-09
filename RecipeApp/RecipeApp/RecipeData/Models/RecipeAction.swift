//
//  RecipeAction.swift
//  RecipeApp
//

import Foundation

/// The possible actions a user can take on a recipe's saved state.
/// Drives the notification copy and the log entry. Raw values are the Core Data storage
/// format — renaming a case without a migration orphans existing rows.
enum RecipeAction: String {
    case saved = "SAVED"
    case removed = "REMOVED"
}

// MARK: - Display Copy
extension RecipeAction {

    /// Notification title: "Recipe saved" / "Recipe removed".
    var notificationTitle: String {
        switch self {
        case .saved: return "Recipe saved"
        case .removed: return "Recipe removed"
        }
    }

    /// Body text shared by the system notification and the in-app log row, so the two can
    /// never drift apart: "<name> added to Saved Recipes."
    func message(recipeName: String) -> String {
        switch self {
        case .saved: return "\(recipeName) added to Saved Recipes."
        case .removed: return "\(recipeName) removed from Saved Recipes."
        }
    }
}
