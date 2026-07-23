//
//  SavedCoordinatorDelegate.swift
//  RecipeApp
//

/// Protocol that lets `SavedCoordinator` report events back to its parent (`DashboardCoordinator`).
protocol SavedCoordinatorDelegate: AnyObject {
    func savedCoordinator(_ coordinator: SavedCoordinator, didSelectRecipeWithId id: Int)
}
