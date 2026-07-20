//
//  AddViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

class AddViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: AddCoordinator?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Recipe"
        view.backgroundColor = .systemOrange
        isModalInPresentation = true

        // Add Close/Dismiss button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
    }

    @objc private func closeTapped() {
        coordinator?.close()
    }
}

// MARK: - Instantiation
extension AddViewController {
    static func instantiate() -> AddViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "AddViewController"
        ) as? AddViewController else {
            fatalError("AddViewController not found in Dashboard.storyboard")
        }
        return vc
    }
}
