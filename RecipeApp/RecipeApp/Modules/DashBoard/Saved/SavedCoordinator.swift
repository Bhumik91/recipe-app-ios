//
//  SavedCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class SavedCoordinator: Coordinator {
    // MARK: - Properties
    var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordinator
    func start() {
        let savedVC = SavedViewController.instantiate()
        savedVC.coordinator = self
        navigationController.setViewControllers([savedVC], animated: false)
    }
}
