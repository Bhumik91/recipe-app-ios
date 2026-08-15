//
//  NotificationCoordinatorDelegate.swift
//  RecipeApp
//

/// Lets `NotificationCoordinator` report events back to `DashboardCoordinator`.
protocol NotificationCoordinatorDelegate: AnyObject {
    func notificationCoordinator(_ coordinator: NotificationCoordinator, didSelectRecipeWithId id: Int)
}
