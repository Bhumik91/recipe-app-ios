//
//  HomeCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class HomeCoordinator: Coordinator {
    // MARK: - Properties
    var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordinator
    func start() {
        let homeVC = HomeViewController.instantiate()
        homeVC.coordinator = self
        navigationController.setViewControllers([homeVC], animated: false)
    }
}
