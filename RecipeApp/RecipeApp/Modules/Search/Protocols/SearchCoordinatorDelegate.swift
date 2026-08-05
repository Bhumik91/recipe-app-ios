//
//  SearchCoordinatorDelegate.swift
//  RecipeApp
//

/// Protocol that lets `SearchCoordinator` report events back to its parent (`DashboardCoordinator`).
protocol SearchCoordinatorDelegate: AnyObject {
    func searchCoordinator(_ coordinator: SearchCoordinator, didSelectRecipeWithId id: Int)
    func searchCoordinatorDidFinish(_ coordinator: SearchCoordinator)
}
