//
//  NotificationDeepLink.swift
//  RecipeApp
//

import Foundation

/// Where a tapped notification should take the user.
/// The key name is kept identical to Android's intent extra.
enum NotificationDeepLink: Equatable, Sendable {
    case notificationTab(recipeId: Int?)
}

// MARK: - userInfo Encoding
extension NotificationDeepLink {

    private enum Keys {
        static let openNotificationTab = "open_notification_tab"
        static let recipeId = "recipeId"
    }

    /// Payload attached to `UNMutableNotificationContent.userInfo`.
    var userInfo: [String: Any] {
        switch self {
        case .notificationTab(let recipeId):
            var info: [String: Any] = [Keys.openNotificationTab: true]
            if let recipeId { info[Keys.recipeId] = recipeId }
            return info
        }
    }

    /// Reads a deep link back out of a delivered notification's `userInfo`, or nil when the
    /// payload isn't one we routed.
    init?(userInfo: [AnyHashable: Any]) {
        guard userInfo[Keys.openNotificationTab] as? Bool == true else { return nil }
        self = .notificationTab(recipeId: userInfo[Keys.recipeId] as? Int)
    }
}

/// Buffers a deep link that arrives before `AppCoordinator` exists — a cold-launch tap
/// reaches `AppDelegate` first. Shared because `AppDelegate` and `SceneDelegate` have no
/// injection seam between them.
@MainActor
final class NotificationDeepLinkRouter {

    // MARK: - Shared
    static let shared = NotificationDeepLinkRouter()

    // MARK: - Properties
    private var pendingDeepLink: NotificationDeepLink?

    /// Set by `AppCoordinator`. Assigning a handler drains anything buffered before it existed.
    var handler: ((NotificationDeepLink) -> Void)? {
        didSet { drainPending() }
    }

    // MARK: - Init
    init() {}

    // MARK: - Routing
    /// Routes immediately when a handler is installed, otherwise buffers until one is.
    func route(_ deepLink: NotificationDeepLink) {
        guard let handler else {
            pendingDeepLink = deepLink
            return
        }
        handler(deepLink)
    }

    private func drainPending() {
        guard let pendingDeepLink, let handler else { return }
        self.pendingDeepLink = nil
        handler(pendingDeepLink)
    }
}
