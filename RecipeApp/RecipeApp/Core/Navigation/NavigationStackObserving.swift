//
//  NavigationStackObserving.swift
//  RecipeApp
//

import UIKit

/// Lets several objects observe one navigation stack, since UIKit offers a single
/// `UINavigationControllerDelegate` slot.
@MainActor
protocol NavigationStackObserving: AnyObject {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool)
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool)
}

// Both callbacks are optional in practice — the container only needs `willShow`,
// coordinators only need `didShow`.
extension NavigationStackObserving {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {}
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {}
}
