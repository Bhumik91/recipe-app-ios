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
        recipeDetailVC.hidesBottomBarWhenPushed = true
        navigationController.delegate = self
        navigationController.pushViewController(recipeDetailVC, animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension RecipeDetailCoordinator: UINavigationControllerDelegate {
    // Fires after ANY pop that reveals a different top view controller — the floating back
    // button's plain popViewController(animated:) and the interactive swipe-back gesture both
    // land here, so this is the one place that needs to notice the screen is gone and clean up.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard !navigationController.viewControllers.contains(where: { $0 is RecipeDetailViewController }) else { return }
        navigationController.delegate = nil
        parentDelegate?.recipeDetailCoordinatorDidFinish(self)
    }
}
