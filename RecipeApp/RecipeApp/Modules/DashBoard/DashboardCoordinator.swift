//
//  DashboardCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
import UIKit
final class DashboardCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentDelegate: DashboardCoordinatorDelegate?
    // MARK: - Constants
    let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    // MARK: - Coordinator
    func start() {
        showDashboard()
    }
}
// MARK: - Navigation
extension DashboardCoordinator {
    private func showDashboard() {
        guard let dashboardVC = storyboard.instantiateViewController(
            withIdentifier: "DashboardViewController"
        ) as? DashboardViewController else {
            fatalError("DashboardViewController not found in Auth.storyboard")
        }
        dashboardVC.coordinatorDelegate = self
        navigationController.setViewControllers([dashboardVC], animated: false)
    }
}
