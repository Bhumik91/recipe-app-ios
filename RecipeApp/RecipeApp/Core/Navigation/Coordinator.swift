//
//  Coordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 10/07/26.
//
import UIKit

@MainActor
protocol Coordinator: AnyObject {
    // MARK: - Methods
    func start()
}
