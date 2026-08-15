//
//  ProfileCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class ProfileCoordinator: ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = ProfileCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: ProfileCoordinatorDelegate?
    let container: DependencyContainer?

    // MARK: - Init
    init(navigationController: UINavigationController, container: DependencyContainer?) {
        self.navigationController = navigationController
        self.container = container
    }

    // MARK: - Coordinator
    func start() {
        guard let container else {
            fatalError("ProfileCoordinator requires a DependencyContainer")
        }
        let viewModel = ProfileViewModel(
            authRepository: container.authRepository,
            recipeRepository: container.recipeRepository,
            sessionManager: container.sessionManager
        )
        let profileVC = ProfileViewController.instantiate(viewModel: viewModel)
        profileVC.coordinator = self
        navigationController.setViewControllers([profileVC], animated: false)
    }

    // MARK: - Events
    func recipeTapped(id: Int) {
        parentDelegate?.profileCoordinator(self, didSelectRecipeWithId: id)
    }

    func exploreRecipesTapped() {
        parentDelegate?.profileCoordinatorDidTapExploreRecipes(self)
    }

    func didLogout() {
        parentDelegate?.profileCoordinatorDidLogout(self)
    }
}
