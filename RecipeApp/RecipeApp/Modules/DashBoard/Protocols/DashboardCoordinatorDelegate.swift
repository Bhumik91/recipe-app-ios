//
//  DashboardCoordinatorDelegate.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//
/// Protocol that lets `DashboardCoordinator` report events back to its parent (`AppCoordinator`).
/// No events to report yet — add requirements here when the dashboard needs to signal upward
/// (e.g. logout).
protocol DashboardCoordinatorDelegate: AnyObject {
    // TODO: add a logout requirement once the dashboard needs to signal upward.
}
