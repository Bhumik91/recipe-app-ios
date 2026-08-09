// DashboardCoordinator.swift
import UIKit

/// Coordinator responsible for the dashboard tab-bar flow.
/// A `ChildCoordinator` of the app coordinator, and `ParentCoordinator` of the per-tab ones.
final class DashboardCoordinator: ChildCoordinator, ParentCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = DashboardCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: DashboardCoordinatorDelegate?
    var container: DependencyContainer?
    private var dashboardViewController: DashboardViewController?
    // MARK: - ParentCoordinator
    var childCoordinators: [any Coordinator] = []
    // MARK: - Initializer
    init(navigationController: UINavigationController, container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    // MARK: - Start
    func start() {
        let controller = DashboardViewController()
        controller.delegate = self
        let tabs = DashboardTab.allCases
        controller.setTabControllers(tabs.map { makeTab(for: $0) }, tabs: tabs)
        self.dashboardViewController = controller
        // Each tab hosts its own navigation controller, so this outer one would otherwise
        // stack a second, permanently empty bar above every dashboard screen.
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setViewControllers([controller], animated: false)
    }

    // MARK: - Deep Links
    /// Selects the Notification tab when the user taps a recipe notification.
    func showNotificationTab() {
        dashboardViewController?.selectTab(at: DashboardTab.notification.rawValue)
    }
}

// MARK: - Tab factory
private extension DashboardCoordinator {
    /// Returns a navigation controller hosting the coordinator for the given tab.
    /// `DashboardNavigationController` so container and children can both observe the stack.
    func makeTab(for item: DashboardTab) -> DashboardNavigationController {
        let nav = DashboardNavigationController()

        guard let container else {
            assertionFailure("DashboardCoordinator requires a DependencyContainer")
            return nav
        }

        let coordinator: Coordinator
        switch item {
        case .home:
            let homeCoordinator = HomeCoordinator(
                navigationController: nav,
                homeViewModel: HomeViewModel(
                    recipeRepository: container.recipeRepository,
                    sessionManager: container.sessionManager
                ),
                container: container
            )
            homeCoordinator.parentDelegate = self
            coordinator = homeCoordinator
        case .savedRecipe:
            let savedRecipeCoordinator = SavedRecipeCoordinator(navigationController: nav, container: container)
            savedRecipeCoordinator.parentDelegate = self
            coordinator = savedRecipeCoordinator
        case .notification:
            coordinator = NotificationCoordinator(navigationController: nav)
        case .profile:
            let profileCoordinator = ProfileCoordinator(navigationController: nav, container: container)
            profileCoordinator.parentDelegate = self
            coordinator = profileCoordinator
        }

        addChild(coordinator)
        coordinator.start()
        return nav
    }
}

// MARK: - DashboardViewControllerDelegate
extension DashboardCoordinator: DashboardViewControllerDelegate {
    func dashboardViewControllerDidTapAdd(_ controller: DashboardViewController) {
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
// MARK: - HomeCoordinatorDelegate
extension DashboardCoordinator: HomeCoordinatorDelegate {
    func homeCoordinator(_ coordinator: HomeCoordinator, didSelectRecipeWithId id: Int) {
        showRecipeDetail(id: id, on: coordinator.navigationController)
    }

    func homeCoordinatorDidTapSearch(_ coordinator: HomeCoordinator) {
        let searchCoordinator = SearchCoordinator(navigationController: coordinator.navigationController, container: container)
        searchCoordinator.parentDelegate = self
        addChild(searchCoordinator)
        searchCoordinator.start()
    }
}

// MARK: - SearchCoordinatorDelegate
extension DashboardCoordinator: SearchCoordinatorDelegate {
    func searchCoordinator(_ coordinator: SearchCoordinator, didSelectRecipeWithId id: Int) {
        showRecipeDetail(id: id, on: coordinator.navigationController)
    }

    func searchCoordinatorDidFinish(_ coordinator: SearchCoordinator) {
        removeChild(coordinator)
    }
}

// MARK: - SavedRecipeCoordinatorDelegate
extension DashboardCoordinator: SavedRecipeCoordinatorDelegate {
    func savedRecipeCoordinator(_ coordinator: SavedRecipeCoordinator, didSelectRecipeWithId id: Int) {
        showRecipeDetail(id: id, on: coordinator.navigationController)
    }
}

// MARK: - ProfileCoordinatorDelegate
extension DashboardCoordinator: ProfileCoordinatorDelegate {
    func profileCoordinator(_ coordinator: ProfileCoordinator, didSelectRecipeWithId id: Int) {
        showRecipeDetail(id: id, on: coordinator.navigationController)
    }

    func profileCoordinatorDidTapExploreRecipes(_ coordinator: ProfileCoordinator) {
        dashboardViewController?.selectTab(at: DashboardTab.home.rawValue)
    }

    func profileCoordinatorDidLogout(_ coordinator: ProfileCoordinator) {
        parentDelegate?.dashboardCoordinatorDidLogout(self)
    }
}

// MARK: - RecipeDetailCoordinatorDelegate
extension DashboardCoordinator: RecipeDetailCoordinatorDelegate {
    func recipeDetailCoordinatorDidFinish(_ coordinator: RecipeDetailCoordinator) {
        removeChild(coordinator)
    }
}

// MARK: - Recipe Detail
private extension DashboardCoordinator {
    func showRecipeDetail(id: Int, on navigationController: UINavigationController) {
        let recipeDetailCoordinator = RecipeDetailCoordinator(
            navigationController: navigationController,
            recipeId: id,
            container: container
        )
        recipeDetailCoordinator.parentDelegate = self
        addChild(recipeDetailCoordinator)
        recipeDetailCoordinator.start()
    }
}
