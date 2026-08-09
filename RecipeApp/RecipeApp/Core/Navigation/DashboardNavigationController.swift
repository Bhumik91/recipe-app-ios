//
//  DashboardNavigationController.swift
//  RecipeApp
//

import UIKit

/// Navigation controller hosting one dashboard tab.
/// Permanently its own delegate — use `addStackObserver(_:)`, never assign `delegate`.
final class DashboardNavigationController: UINavigationController {
    // MARK: - Properties
    // Weak so a deallocated observer drops out on its own.
    private let observers = NSHashTable<AnyObject>.weakObjects()

    // MARK: - Init
    // Declaring designated inits stops `init()` being inherited.
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    // Delegate is claimed here rather than in viewDidLoad so events are
    // broadcast even for a tab whose view has not been loaded yet.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }

    // MARK: - Observers
    func addStackObserver(_ observer: NavigationStackObserving) {
        observers.add(observer)
    }

    func removeStackObserver(_ observer: NavigationStackObserving) {
        observers.remove(observer)
    }

    private var stackObservers: [NavigationStackObserving] {
        observers.allObjects.compactMap { $0 as? NavigationStackObserving }
    }
}

// MARK: - UINavigationControllerDelegate
extension DashboardNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        stackObservers.forEach {
            $0.navigationController(navigationController, willShow: viewController, animated: animated)
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        stackObservers.forEach {
            $0.navigationController(navigationController, didShow: viewController, animated: animated)
        }
    }
}
