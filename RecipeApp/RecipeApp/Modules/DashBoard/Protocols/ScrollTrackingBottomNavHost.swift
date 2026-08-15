//
//  ScrollTrackingBottomNavHost.swift
//  RecipeApp
//

import UIKit

/// Opt-in for a screen whose scroll position should drive bottom-nav/FAB visibility,
/// layered on top of the push/pop-based `BottomNavHidable`. The screen only exposes
/// its scroll view — it never learns that a bottom nav exists, and `DashboardViewController`
/// never learns which screen it's watching. `DashboardViewController` observes
/// `contentOffset` itself, so conforming doesn't require giving up the scroll view's
/// own `UIScrollViewDelegate`.
@MainActor
protocol ScrollTrackingBottomNavHost: AnyObject {
    var scrollViewDrivingBottomNav: UIScrollView { get }
}
