//
//  HomeCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class HomeCoordinator: ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = HomeCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    var container: DependencyContainer?
    weak var parentDelegate: HomeCoordinatorDelegate?
    private let homeViewModel: HomeViewModel
    // MARK: - Init
    init(navigationController: UINavigationController, homeViewModel: HomeViewModel, container: DependencyContainer? = nil) {
        self.navigationController = navigationController
        self.homeViewModel = homeViewModel
        self.container = container
    }
    // MARK: - Coordinator
    func start() {
        let homeVC = HomeViewController.instantiate(viewModel: homeViewModel)
        homeVC.coordinator = self
        navigationController.setViewControllers([homeVC], animated: false)
    }
    // MARK: - Header taps
    // TODO: push/present the real Search and Filter screens once they exist.
    func searchTapped() {}
    func filterTapped() {}
}
