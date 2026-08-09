//
//  DashboardViewControllerDelegate.swift
//  RecipeApp
//

import Foundation

/// Dashboard container → coordinator. Tab switching stays inside the container
/// (every tab's coordinator is already started); only the FAB opens a new flow.
@MainActor
protocol DashboardViewControllerDelegate: AnyObject {
    func dashboardViewControllerDidTapAdd(_ controller: DashboardViewController)
}
