//
//  ProfileCoordinatorDelegate.swift
//  RecipeApp
//

/// Protocol that lets `ProfileCoordinator` report events back to its parent (`DashboardCoordinator`).
protocol ProfileCoordinatorDelegate: AnyObject {
    func profileCoordinator(_ coordinator: ProfileCoordinator, didSelectRecipeWithId id: Int)
    /// The empty Recipes tab's "Explore Recipes" action — switches to the Home tab.
    func profileCoordinatorDidTapExploreRecipes(_ coordinator: ProfileCoordinator)
    /// Session is already cleared by this point; the parent tears the dashboard down.
    func profileCoordinatorDidLogout(_ coordinator: ProfileCoordinator)
}
