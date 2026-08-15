//
//  ParentCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 17/07/26.
//
import UIKit

/// Anyone who owns and manages child coordinators.
protocol ParentCoordinator: AnyObject, Coordinator {
    var childCoordinators: [any Coordinator] { get set }
    func addChild(_ coordinator: any Coordinator)
    func removeChild(_ coordinator: any Coordinator)
}

extension ParentCoordinator {
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
