//
//  ChildCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 17/07/26.
//
import UIKit

protocol ChildCoordinator: Coordinator {
    // `ParentDelegate` is constrained to class-bound protocols (AnyObject) by convention
    // via each coordinator's typealias — we omit the AnyObject constraint here because
    // Swift does not treat a class-constrained protocol *type* as conforming to AnyObject.
    associatedtype ParentDelegate
    var navigationController: UINavigationController { get set }
    var parentDelegate: ParentDelegate? { get set }
    /// Optional DI container — coordinators that need services provide it;
    /// coordinators with no service dependencies simply return nil.
    var container: DependencyContainer? { get }
}
