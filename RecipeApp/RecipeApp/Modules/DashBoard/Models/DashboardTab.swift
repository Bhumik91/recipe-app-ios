// DashboardTab.swift
import UIKit

enum DashboardTab: Int, CaseIterable {
    case home = 0
    case savedRecipe = 1
    case notification = 2
    case profile = 3

    var icon: UIImage {
        switch self {
        case .home: return UIImage(resource: .icHomeOutlined)
        case .savedRecipe: return UIImage(resource: .icSavedOutlined)
        case .notification: return UIImage(resource: .icNotificationOutlined)
        case .profile: return UIImage(resource: .icProfileOutlined)
        }
    }

    /// UITabBar used to supply this to VoiceOver for free. Now we do.
    var accessibilityLabel: String {
        switch self {
        case .home: return "Home"
        case .savedRecipe: return "Saved recipes"
        case .notification: return "Notifications"
        case .profile: return "Profile"
        }
    }
}
