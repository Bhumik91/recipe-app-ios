//
//  UIViewController+NavigationBarVisibility.swift
//  RecipeApp
//

import UIKit

extension UIViewController {
    /// Toggles the navigation bar only if it isn't already in that state, so driving
    /// this from `scrollViewDidScroll` doesn't re-trigger the animation on every tick.
    func setNavigationBar(hidden: Bool, animated: Bool = true) {
        guard navigationController?.isNavigationBarHidden != hidden else { return }
        navigationController?.setNavigationBarHidden(hidden, animated: animated)
    }
}
