//
//  SystemRecipeNotifier.swift
//  RecipeApp
//

import UserNotifications

/// `UNUserNotificationCenter`-backed implementation of `RecipeNotifying`.
/// Posts a local notification when a recipe is saved or removed, and routes a tap to the
/// Notification tab.
final class SystemRecipeNotifier: RecipeNotifying {

    // MARK: - Dependencies
    private let permissionManager: PermissionManaging
    private let center: UNUserNotificationCenter

    // MARK: - Init
    init(
        permissionManager: PermissionManaging,
        center: UNUserNotificationCenter = .current()
    ) {
        self.permissionManager = permissionManager
        self.center = center
    }

    // MARK: - RecipeNotifying
    /// Posts a notification, or silently does nothing without authorization.
    /// Runs detached because the permission check is async; the caller never waits.
    func notify(recipeId: Int, recipeName: String, action: RecipeAction) {
        let permissionManager = self.permissionManager
        let center = self.center

        Task {
            // Respect the permission — never assume granted.
            guard await permissionManager.isGranted(.notifications) else { return }

            let content = UNMutableNotificationContent()
            content.title = action.notificationTitle
            content.body = action.message(recipeName: recipeName)
            content.sound = .default
            content.categoryIdentifier = NotificationCategories.recipeActivity
            content.userInfo = NotificationDeepLink.notificationTab(recipeId: recipeId).userInfo

            // Nil trigger delivers immediately; the recipe-keyed id replaces rather than stacks.
            let request = UNNotificationRequest(
                identifier: Self.identifier(for: recipeId),
                content: content,
                trigger: nil
            )

            // Failures here are non-actionable for the user (throttling, a permission revoked
            // between the check above and this call) — the log row is already the durable record.
            try? await center.add(request)
        }
    }

    // MARK: - Helpers
    private static func identifier(for recipeId: Int) -> String {
        "recipe_\(recipeId)"
    }
}
