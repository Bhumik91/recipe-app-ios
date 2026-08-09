//
//  AppCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 10/07/26.
// this coordinator owns the window, decides which flow is in root
import UIKit

final class AppCoordinator: ParentCoordinator {
    // MARK: - Properties
    var childCoordinators: [any Coordinator] = []
    // MARK: - Dependencies
    let window: UIWindow
    /// Rebuilt on logout — the storage managers capture `sessionManager.userId` at
    /// construction, so a stale container would serve the previous user's data.
    private var container: DependencyContainer
    // MARK: - Initializer
    init(window: UIWindow, container: DependencyContainer) {
        self.window = window
        self.container = container
    }
    // MARK: - Coordinator
    func start() {
        installNotificationDeepLinkHandler()
        if(container.sessionManager.isLoggedIn) {
            showDashboard()
            return
        }
        // Onboarding is a one-time introduction. Once it's been through, a logged-out
        // launch (including the one right after a logout) belongs on Login instead.
        if container.sessionManager.hasCompletedOnboarding {
            showAuth()
            return
        }
        showOnboarding()
    }
}
// MARK: - Notification Deep Links
extension AppCoordinator {
    /// Installing the handler also drains anything the app delegate buffered before this
    /// coordinator existed — the cold-launch-from-a-notification-tap case.
    private func installNotificationDeepLinkHandler() {
        NotificationDeepLinkRouter.shared.handler = { [weak self] deepLink in
            self?.handle(deepLink)
        }
    }

    private func handle(_ deepLink: NotificationDeepLink) {
        // A logged-out user has no dashboard to route into; the tap just opens the app.
        guard let dashboardCoordinator = childCoordinators.compactMap({ $0 as? DashboardCoordinator }).first else { return }
        switch deepLink {
        case .notificationTab:
            dashboardCoordinator.showNotificationTab()
        }
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
        let dashboardCoordinator = DashboardCoordinator(
            navigationController: nav,
            container: container
        )
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
        container.sessionManager.markOnboardingCompleted()
        showAuth()
    }
}
// MARK: - AuthCoordinatorDelegate
extension AppCoordinator: AuthCoordinatorDelegate {
    func authFlowDidFinish(_ coordinator: any Coordinator) {
        removeChild(coordinator)
        // Covers anyone who onboarded before this flag existed: reaching Login at all
        // means the intro is behind them.
        container.sessionManager.markOnboardingCompleted()
        showDashboard()
    }
}
// MARK: - DashboardCoordinatorDelegate
extension AppCoordinator: DashboardCoordinatorDelegate {
    /// Session already cleared. Rebuild the dependency graph before showing auth — the
    /// stores bake in the userId they were created with.
    func dashboardCoordinatorDidLogout(_ coordinator: DashboardCoordinator) {
        removeChild(coordinator)
        childCoordinators.removeAll()
        container = DependencyContainer()
        showAuth()
    }
}
