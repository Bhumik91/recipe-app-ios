//
//  DashboardCoordinatorDelegate.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
/// Protocol that lets `DashboardCoordinator` report events back to its parent (`AppCoordinator`).
protocol DashboardCoordinatorDelegate: AnyObject {
    /// Session already cleared. The parent must rebuild the dependency graph before showing
    /// auth, so nothing scoped to the departing user survives.
    func dashboardCoordinatorDidLogout(_ coordinator: DashboardCoordinator)
}
