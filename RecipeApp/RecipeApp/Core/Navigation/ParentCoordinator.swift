//
//  ParentCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 17/07/26.
//
import UIKit

protocol ParentCoordinator: Coordinator {
    var window: UIWindow { get }
    // Uses `any Coordinator` (not `any ChildCoordinator`) intentionally:
    // ChildCoordinator has an associatedtype which prevents its use as an
    // existential inside another protocol requirement.
    var childCoordinators: [any Coordinator] { get set }
    func addChild(_ coordinator: any Coordinator)
    func removeChild(_ coordinator: any Coordinator)
}

extension ParentCoordinator {
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll {
            $0 === coordinator
        }
    }
}
