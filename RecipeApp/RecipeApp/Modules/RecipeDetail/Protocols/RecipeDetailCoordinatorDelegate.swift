//
//  RecipeDetailCoordinatorDelegate.swift
//  RecipeApp
//

/// Protocol that lets `RecipeDetailCoordinator` report events back to its parent
/// (`DashboardCoordinator`).
protocol RecipeDetailCoordinatorDelegate: AnyObject {
    func recipeDetailCoordinatorDidFinish(_ coordinator: RecipeDetailCoordinator)
}
