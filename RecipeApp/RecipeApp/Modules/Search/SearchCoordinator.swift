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
        navigationController.delegate = self
        navigationController.pushViewController(searchVC, animated: true)
    }

    // MARK: - Recipe selection
    func recipeTapped(id: Int) {
        parentDelegate?.searchCoordinator(self, didSelectRecipeWithId: id)
    }
}

// MARK: - UINavigationControllerDelegate
extension SearchCoordinator: UINavigationControllerDelegate {
    // Fires after ANY pop that reveals a different top view controller — the back button's
    // plain popViewController(animated:) and the interactive swipe-back gesture both land
    // here, so this is the one place that needs to notice the screen is gone and clean up.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard !navigationController.viewControllers.contains(where: { $0 is SearchViewController }) else { return }
        navigationController.delegate = nil
        parentDelegate?.searchCoordinatorDidFinish(self)
    }
}
