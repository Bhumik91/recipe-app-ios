//
//  BottomNavWithFabDelegate.swift
//  RecipeApp
//

import Foundation

/// Reports raw user intent from the bottom bar. The view knows nothing about
/// tabs, coordinators, or what "Add" means — its owner decides.
@MainActor
protocol BottomNavWithFabDelegate: AnyObject {
    func bottomNav(_ bottomNav: BottomNavWithFab, didSelectItemAt index: Int)
    func bottomNavDidTapFab(_ bottomNav: BottomNavWithFab)
}
