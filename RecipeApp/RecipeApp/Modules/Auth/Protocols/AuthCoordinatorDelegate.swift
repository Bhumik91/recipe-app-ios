//
//  AuthCoordinatorDelegate.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 10/07/26.
//

protocol AuthCoordinatorDelegate: AnyObject {
    func authFlowDidFinish(_ coordinator: Coordinator)
}
