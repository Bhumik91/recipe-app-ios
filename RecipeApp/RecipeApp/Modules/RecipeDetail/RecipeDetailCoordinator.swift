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
    // Fires after any pop revealing a different top controller — back button and swipe-back
    // both land here, so this is the single cleanup point.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard !navigationController.viewControllers.contains(where: { $0 is RecipeDetailViewController }) else { return }
        navigationController.delegate = nil
        parentDelegate?.recipeDetailCoordinatorDidFinish(self)
    }
}
