// DashboardCoordinator.swift
import UIKit

/// Coordinator responsible for the dashboard tab-bar flow.
///
/// Conforms to `ChildCoordinator` (it is a child of the app coordinator) and to
/// `ParentCoordinator` (it owns the per-tab child coordinators). Child
/// management (`addChild`/`removeChild`) is provided by `ParentCoordinator`.
final class DashboardCoordinator: ChildCoordinator, ParentCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = DashboardCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: DashboardCoordinatorDelegate?
    var container: DependencyContainer?
    private var tabBarController: DashboardTabBarController?
    // MARK: - ParentCoordinator
    var childCoordinators: [any Coordinator] = []
    // MARK: - Constants
    let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
    // MARK: - Initializer
    init(navigationController: UINavigationController, container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    // MARK: - Start
    func start() {
        let controller = DashboardTabBarController()
        controller.tabBarDelegate = self
        controller.viewControllers = TabBarItem.allCases.map { makeTab(for: $0) }
        self.tabBarController = controller
        navigationController.setViewControllers([controller], animated: false)
    }
}

// MARK: - Tab factory
private extension DashboardCoordinator {
    /// Returns a navigation controller hosting the dedicated coordinator for the given tab item.
    func makeTab(for item: TabBarItem) -> UINavigationController {
        let nav = UINavigationController()
        nav.tabBarItem = UITabBarItem(
            title: nil,
            image: item.unselectedIcon,
            tag: item.rawValue
        )

        let coordinator: Coordinator
        switch item {
        case .home:
            coordinator = HomeCoordinator(navigationController: nav)
        case .saved:
            coordinator = SavedCoordinator(navigationController: nav)
        case .notification:
            coordinator = NotificationCoordinator(navigationController: nav)
        case .profile:
            coordinator = ProfileCoordinator(navigationController: nav)
        }

        addChild(coordinator)
        coordinator.start()
        return nav
    }
}

// MARK: - DashboardTabBarDelegate
extension DashboardCoordinator: DashboardTabBarDelegate {
    func dashboardTabBarDidTapAdd() {
        let addCoordinator = AddCoordinator(navigationController: navigationController)
        addCoordinator.parentDelegate = self
        addChild(addCoordinator)
        addCoordinator.start()
    }
}

// MARK: - AddCoordinatorDelegate
extension DashboardCoordinator: AddCoordinatorDelegate {
    func addCoordinatorDidFinish(_ coordinator: AddCoordinator) {
        removeChild(coordinator)
    }
}
