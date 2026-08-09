//
//  NotificationLogUIModel.swift
//  RecipeApp
//

import Foundation

/// One row of the notification log, as the UI consumes it.
/// The value-type boundary around Core Data — managed objects never leave the store.
struct NotificationLogUIModel: Hashable, Identifiable {
    let id: UUID
    let recipeId: Int
    let recipeName: String
    let recipeImageURL: String?
    let action: RecipeAction
    let timestamp: Date

    /// Body copy, shared with the system notification so the two can't drift.
    var message: String {
        action.message(recipeName: recipeName)
    }
}

// MARK: - Mapping
extension NotificationLog {
    /// Maps into a detached value type. Call on the object's own context queue.
    func toUIModel() -> NotificationLogUIModel {
        NotificationLogUIModel(
            id: id,
            recipeId: Int(recipeId),
            recipeName: recipeName,
            recipeImageURL: recipeImageURL,
            // An unknown raw value means a newer build wrote it; showing it beats dropping it.
            action: RecipeAction(rawValue: action) ?? .saved,
            timestamp: timestamp
        )
    }
}
