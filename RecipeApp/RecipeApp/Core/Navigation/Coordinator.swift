//
//  Coordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 10/07/26.
//
import UIKit

protocol Coordinator: AnyObject {
    // MARK: - Properties
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    // MARK: - Methods
    func start()
}
// MARK: - Child Management
extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
