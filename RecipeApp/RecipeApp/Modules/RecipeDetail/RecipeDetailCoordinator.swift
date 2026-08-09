//
//  RecipeDetailCoordinator.swift
//  RecipeApp
//

import UIKit

final class RecipeDetailCoordinator: NSObject, ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = RecipeDetailCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: RecipeDetailCoordinatorDelegate?
    let container: DependencyContainer?
    private let recipeId: Int

    // MARK: - Init
    init(navigationController: UINavigationController, recipeId: Int, container: DependencyContainer?) {
        self.navigationController = navigationController
        self.recipeId = recipeId
        self.container = container
    }

    // MARK: - Coordinator
    func start() {
        guard let container else {
            fatalError("RecipeDetailCoordinator requires a DependencyContainer")
        }
        let viewModel = RecipeDetailViewModel(recipeRepository: container.recipeRepository, recipeId: recipeId)
        let recipeDetailVC = RecipeDetailViewController.instantiate(viewModel: viewModel)
        // The bottom nav hides itself via RecipeDetailViewController's BottomNavHidable
        // conformance — `hidesBottomBarWhenPushed` only works under a UITabBarController.
        (navigationController as? DashboardNavigationController)?.addStackObserver(self)
        navigationController.pushViewController(recipeDetailVC, animated: true)
    }
}

// MARK: - NavigationStackObserving
extension RecipeDetailCoordinator: NavigationStackObserving {
    // Fires after any pop revealing a different top controller — back button and swipe-back
    // both land here, so this is the single cleanup point.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard !navigationController.viewControllers.contains(where: { $0 is RecipeDetailViewController }) else { return }
        (navigationController as? DashboardNavigationController)?.removeStackObserver(self)
        parentDelegate?.recipeDetailCoordinatorDidFinish(self)
    }
}
