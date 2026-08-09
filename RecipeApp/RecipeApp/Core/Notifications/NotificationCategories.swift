//
//  NotificationCategories.swift
//  RecipeApp
//

import UserNotifications

/// Registry for the notification categories the app posts under.
/// The identifier is kept identical to Android's channel id.
enum NotificationCategories {

    static let recipeActivity = "recipe_activity_channel"

    /// Registers every category with the system. Safe to call more than once — the last call
    /// replaces the registered set. Call once at launch, before any notification is posted.
    static func register(on center: UNUserNotificationCenter = .current()) {
        let recipeActivityCategory = UNNotificationCategory(
            identifier: recipeActivity,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([recipeActivityCategory])
    }
}
