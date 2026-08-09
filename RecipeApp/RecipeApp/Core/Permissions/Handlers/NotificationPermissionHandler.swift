//
//  NotificationPermissionHandler.swift
//  RecipeApp
//

import UserNotifications

/// `UserNotifications` implementation of `PermissionHandling`.
/// Covers both check and request — `requestAuthorization` needs no host view controller.
final class NotificationPermissionHandler: PermissionHandling {

    // MARK: - PermissionHandling
    let permission: AppPermission = .notifications

    // MARK: - Dependencies
    private let center: UNUserNotificationCenter
    /// Kept here rather than on `AppPermission` so `UserNotifications` types stay out of the
    /// shared enum — see the note in `AppPermission`.
    private let options: UNAuthorizationOptions

    // MARK: - Init
    init(
        center: UNUserNotificationCenter = .current(),
        options: UNAuthorizationOptions = [.alert, .sound, .badge]
    ) {
        self.center = center
        self.options = options
    }

    // MARK: - Status
    func status() async -> PermissionStatus {
        Self.map(await center.notificationSettings().authorizationStatus)
    }

    // MARK: - Request
    @discardableResult
    func request() async -> PermissionStatus {
        // Asking again after the user has answered shows nothing at all, so report the settled
        // answer instead of pretending a prompt happened.
        let current = await status()
        guard current.canPrompt else { return current }

        // A throw here is system-level, not a refusal; either way it is "not granted".
        guard (try? await center.requestAuthorization(options: options)) != nil else {
            return .denied
        }
        return await status()
    }

    // MARK: - Mapping
    private static func map(_ status: UNAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        // `.provisional` and `.ephemeral` both allow delivery without an explicit grant,
        // so they count as authorized for our purposes.
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        @unknown default:
            return .denied
        }
    }
}
