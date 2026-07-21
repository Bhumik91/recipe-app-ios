//
//  NotificationCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class NotificationCoordinator: Coordinator {
    // MARK: - Properties
    var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordinator
    func start() {
        let notificationVC = NotificationViewController.instantiate()
        notificationVC.coordinator = self
        navigationController.setViewControllers([notificationVC], animated: false)
    }
}
