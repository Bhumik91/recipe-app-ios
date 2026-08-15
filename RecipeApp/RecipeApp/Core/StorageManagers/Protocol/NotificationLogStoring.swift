//
//  NotificationLogStoring.swift
//  RecipeApp
//

import Combine

/// Append-only history of every save/remove. Written regardless of notification permission,
/// and scoped to whoever is logged in at the time of the call.
protocol NotificationLogStoring {
    /// Appends a row. Fire-and-forget — never blocks the caller.
    func log(recipeId: Int, recipeName: String, recipeImageURL: String?, action: RecipeAction)

    /// Emits the current user's rows, newest first, and again on every change.
    func observeLogs() -> AnyPublisher<[NotificationLogUIModel], Never>
}
