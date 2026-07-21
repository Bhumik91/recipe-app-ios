//
//  AddCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

final class AddCoordinator: ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = AddCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: AddCoordinatorDelegate?
    var container: DependencyContainer? { nil }

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordinator
    func start() {
        let addVC = AddViewController.instantiate()
        addVC.coordinator = self

        let modalNav = UINavigationController(rootViewController: addVC)
        modalNav.modalPresentationStyle = .pageSheet
        navigationController.present(modalNav, animated: true)
    }

    // MARK: - Dismissal
    func close() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.parentDelegate?.addCoordinatorDidFinish(self)
        }
    }
}
