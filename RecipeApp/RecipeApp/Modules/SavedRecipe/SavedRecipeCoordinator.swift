//
//  SavedRecipeCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class SavedRecipeCoordinator: ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = SavedRecipeCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: SavedRecipeCoordinatorDelegate?
    let container: DependencyContainer?

    // MARK: - Init
    init(navigationController: UINavigationController, container: DependencyContainer?) {
        self.navigationController = navigationController
        self.container = container
    }

    // MARK: - Coordinator
    func start() {
        guard let container else {
            fatalError("SavedRecipeCoordinator requires a DependencyContainer")
        }
        let viewModel = SavedRecipeViewModel(recipeRepository: container.recipeRepository)
        let savedVC = SavedRecipeViewController.instantiate(viewModel: viewModel)
        savedVC.coordinator = self
        navigationController.setViewControllers([savedVC], animated: false)
    }

    // MARK: - Recipe selection
    func recipeTapped(id: Int) {
        parentDelegate?.savedRecipeCoordinator(self, didSelectRecipeWithId: id)
    }

    func exploreRecipesTapped() {
        parentDelegate?.savedRecipeCoordinatorDidTapExploreRecipes(self)
    }
}
