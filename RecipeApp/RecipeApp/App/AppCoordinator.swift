//
//  AppCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 10/07/26.
// this coordinator owns the window, decides which flow is in root
import UIKit

final class AppCoordinator: Coordinator {
    // MARK: - Properties
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    // MARK: - Dependencies
    private let window: UIWindow
    private let container: DependencyContainer
    // MARK: - Initializer
    init(window: UIWindow, container: DependencyContainer) {
        self.window = window
        self.container = container
    }
    // MARK: - Coordinator
    func start() {
        if(container.sessionManager.isLoggedIn) {
            showDashboard()
            return
        }
        showOnboarding()
    }
}
// MARK: - Navigation
extension AppCoordinator {
    private func setRoot(_ vc: UIViewController) {
        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
    private func showOnboarding() {
        let nav = UINavigationController()
        let onboardingCoordinator = OnBoardingCoordinator(navigationController: nav)
        onboardingCoordinator.parentDelegate = self
        addChild(onboardingCoordinator)
        onboardingCoordinator.start()
        setRoot(nav)
    }
    private func showAuth() {
        let nav = UINavigationController()
        let authCoordinator = AuthCoordinator(navigationController: nav, container: container)
        authCoordinator.parentDelegate = self
        addChild(authCoordinator)
        authCoordinator.start()
        setRoot(nav)
    }
    private func showDashboard() {
        let nav = UINavigationController()
        let dashboardCoordinator = DashboardCoordinator(navigationController: nav, container: container)
        dashboardCoordinator.parentDelegate = self
        addChild(dashboardCoordinator)
        dashboardCoordinator.start()
        setRoot(nav)
    }
}
// MARK: - OnBoardingCoordinatorDelegate
extension AppCoordinator: OnBoardingCoordinatorDelegate {
    func onBoardingFlowDidFinish(_ coordinator: any Coordinator) {
        removeChild(coordinator)
        showAuth()
    }
}
// MARK: - AuthCoordinatorDelegate
extension AppCoordinator: AuthCoordinatorDelegate {
    func authFlowDidFinish(_ coordinator: any Coordinator) {
        removeChild(coordinator)
        showDashboard()
    }
}
// MARK: - DashboardCoordinatorDelegate
extension AppCoordinator: DashboardCoordinatorDelegate {
    
}
