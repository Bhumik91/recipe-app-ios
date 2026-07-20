//
//  DashboardCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import UIKit
final class DashboardCoordinator: ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = DashboardCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: DashboardCoordinatorDelegate?
    var container: DependencyContainer?
    // MARK: - Constants
    let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
    // MARK: - Initializer
    init(navigationController: UINavigationController, container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    // MARK: - Coordinator
    func start() {
        showDashboard()
    }

    func logoutTapped() {
        container?.sessionManager.clearSession()
        exit(0)
    }
}
// MARK: - Navigation
extension DashboardCoordinator {
    private func showDashboard() {
        guard let dashboardVC = storyboard.instantiateViewController(
            withIdentifier: "DashboardViewController"
        ) as? DashboardViewController else {
            fatalError("DashboardViewController not found in Dashboard.storyboard")
        }
        dashboardVC.userName = container?.sessionManager.userName
        dashboardVC.coordinatorDelegate = self
        navigationController.setViewControllers([dashboardVC], animated: false)
    }
}
