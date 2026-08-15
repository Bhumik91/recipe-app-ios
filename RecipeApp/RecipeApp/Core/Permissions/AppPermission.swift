//
//  AppPermission.swift
//  RecipeApp
//

import Foundation

/// Single source of truth for every runtime permission the app can request.
///
/// To add one: add a case here, implement `PermissionHandling`, register it in
/// `PermissionManager`. Kept free of framework imports so handlers own those types.
enum AppPermission: CaseIterable {
    case notifications

    // MARK: - Rationale Copy
    /// Shown before the system prompt, when the app needs to explain why it is asking.
    var rationaleTitle: String {
        switch self {
        case .notifications: return "Stay updated"
        }
    }

    var rationaleMessage: String {
        switch self {
        case .notifications:
            return "Allow notifications so we can let you know when a recipe is saved or removed."
        }
    }

    /// Shown when the permission was refused. iOS will not present the system prompt a second
    /// time, so the only remaining path for the user is the Settings app.
    var deniedMessage: String {
        switch self {
        case .notifications:
            return "Notifications are turned off. You can turn them back on in Settings."
        }
    }
}
