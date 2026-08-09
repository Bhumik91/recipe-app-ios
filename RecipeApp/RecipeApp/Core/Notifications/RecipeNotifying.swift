//
//  RecipeNotifying.swift
//  RecipeApp
//

import Foundation

/// Dispatches system notifications for recipe activity, keeping `UserNotifications` out of
/// the storage and UI layers. Non-throwing and non-async: callers fire and forget.
protocol RecipeNotifying: AnyObject {
    func notify(recipeId: Int, recipeName: String, action: RecipeAction)
}
