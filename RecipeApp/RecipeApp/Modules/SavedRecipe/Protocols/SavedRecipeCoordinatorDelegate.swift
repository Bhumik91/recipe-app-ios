//
//  SavedRecipeCoordinatorDelegate.swift
//  RecipeApp
//

/// Protocol that lets `SavedRecipeCoordinator` report events back to its parent (`DashboardCoordinator`).
protocol SavedRecipeCoordinatorDelegate: AnyObject {
    func savedRecipeCoordinator(_ coordinator: SavedRecipeCoordinator, didSelectRecipeWithId id: Int)
}
