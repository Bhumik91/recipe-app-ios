//
//  SavedRecipeCoordinatorDelegate.swift
//  RecipeApp
//

/// Protocol that lets `SavedRecipeCoordinator` report events back to its parent (`DashboardCoordinator`).
protocol SavedRecipeCoordinatorDelegate: AnyObject {
    func savedRecipeCoordinator(_ coordinator: SavedRecipeCoordinator, didSelectRecipeWithId id: Int)
    /// The empty state's "Explore Recipes" action — switches to the Home tab.
    func savedRecipeCoordinatorDidTapExploreRecipes(_ coordinator: SavedRecipeCoordinator)
}
