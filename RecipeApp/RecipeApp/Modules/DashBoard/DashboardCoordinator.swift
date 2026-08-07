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
        // Each tab hosts its own navigation controller, so this outer one would otherwise
        // stack a second, permanently empty bar above every dashboard screen.
        navigationController.setNavigationBarHidden(true, animated: false)
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
        tabBarController?.selectedIndex = TabBarItem.home.rawValue
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
