// TabBarItem.swift
import UIKit

enum TabBarItem: Int, CaseIterable {
    case home = 0
    case saved = 1
    case notification = 2
    case profile = 3

    var unselectedIcon: UIImage {
        switch self {
        case .home: return UIImage(resource: .icHomeOutlined)
        case .saved: return UIImage(resource: .icSavedOutlined)
        case .notification: return UIImage(resource: .icNotificationOutlined)
        case .profile: return UIImage(resource: .icProfileOutlined)
        }
    }
}
