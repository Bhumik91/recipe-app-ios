//
//  HomeCoordinatorDelegate.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 21/07/26.
//

/// Protocol that lets `HomeCoordinator` report events back to its parent (`DashboardCoordinator`).
protocol HomeCoordinatorDelegate: AnyObject {
    func homeCoordinator(_ coordinator: HomeCoordinator, didSelectRecipeWithId id: Int)
}
