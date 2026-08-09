//
//  BottomNavHidable.swift
//  RecipeApp
//

import Foundation

/// Opt-in replacement for `hidesBottomBarWhenPushed`, which needs a real `UITabBarController`.
/// Opt-in because some pushed screens (Search) deliberately keep the bar visible.
@MainActor
protocol BottomNavHidable: AnyObject {
    var hidesBottomNav: Bool { get }
}

extension BottomNavHidable {
    var hidesBottomNav: Bool { true }
}
