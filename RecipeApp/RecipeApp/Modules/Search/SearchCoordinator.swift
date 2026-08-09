//
//  SearchCoordinator.swift
//  RecipeApp
//

import UIKit

final class SearchCoordinator: NSObject, ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = SearchCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: SearchCoordinatorDelegate?
    let container: DependencyContainer?

    // MARK: - Init
    init(navigationController: UINavigationController, container: DependencyContainer?) {
        self.navigationController = navigationController
        self.container = container
    }

    // MARK: - Coordinator
    func start() {
        guard let container else {
            assertionFailure("SearchCoordinator requires a DependencyContainer")
            return
        }
        let viewModel = SearchViewModel(
            recipeRepository: container.recipeRepository,
            recentSearchesManager: container.recentSearchesManager
        )
        let searchVC = SearchViewController.instantiate(viewModel: viewModel)
        searchVC.coordinator = self
        // Observer, not `navigationController.delegate` — several objects watch this stack
        // and the single delegate slot let the last assignment cancel the others.
        (navigationController as? DashboardNavigationController)?.addStackObserver(self)
        navigationController.pushViewController(searchVC, animated: true)
    }

    // MARK: - Recipe selection
    func recipeTapped(id: Int) {
        parentDelegate?.searchCoordinator(self, didSelectRecipeWithId: id)
    }
}

// MARK: - NavigationStackObserving
extension SearchCoordinator: NavigationStackObserving {
    // Fires after any pop revealing a different top controller — back button and swipe-back
    // both land here, so this is the single cleanup point.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard !navigationController.viewControllers.contains(where: { $0 is SearchViewController }) else { return }
        (navigationController as? DashboardNavigationController)?.removeStackObserver(self)
        parentDelegate?.searchCoordinatorDidFinish(self)
    }
}
