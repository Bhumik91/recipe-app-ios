//
//  ProfileCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class ProfileCoordinator: Coordinator {
    // MARK: - Properties
    var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordinator
    func start() {
        let profileVC = ProfileViewController.instantiate()
        profileVC.coordinator = self
        navigationController.setViewControllers([profileVC], animated: false)
    }
}
