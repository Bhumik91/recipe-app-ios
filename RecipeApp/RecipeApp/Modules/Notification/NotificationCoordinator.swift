//
//  NotificationCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class NotificationCoordinator: ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = NotificationCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    var container: DependencyContainer?
    weak var parentDelegate: NotificationCoordinatorDelegate?

    // MARK: - Init
    init(navigationController: UINavigationController, container: DependencyContainer? = nil) {
        self.navigationController = navigationController
        self.container = container
    }

    // MARK: - Coordinator
    func start() {
        guard let container else {
            assertionFailure("NotificationCoordinator requires a DependencyContainer")
            return
        }
        let viewModel = NotificationViewModel(notificationLogStore: container.notificationLogStore)
        let notificationVC = NotificationViewController.instantiate(viewModel: viewModel)
        notificationVC.coordinator = self
        navigationController.setViewControllers([notificationVC], animated: false)
    }

    // MARK: - Recipe selection
    func recipeTapped(id: Int) {
        parentDelegate?.notificationCoordinator(self, didSelectRecipeWithId: id)
    }
}
