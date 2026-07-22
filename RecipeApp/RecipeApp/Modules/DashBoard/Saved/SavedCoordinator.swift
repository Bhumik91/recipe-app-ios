//
//  SavedCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class SavedCoordinator: ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = SavedCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: SavedCoordinatorDelegate?
    let container: DependencyContainer?

    // MARK: - Init
    init(navigationController: UINavigationController, container: DependencyContainer?) {
        self.navigationController = navigationController
        self.container = container
    }

    // MARK: - Coordinator
    func start() {
        guard let container else {
            fatalError("SavedCoordinator requires a DependencyContainer")
        }
        let viewModel = SavedViewModel(recipeRepository: container.recipeRepository)
        let savedVC = SavedViewController.instantiate(viewModel: viewModel)
        savedVC.coordinator = self
        navigationController.setViewControllers([savedVC], animated: false)
    }
}
