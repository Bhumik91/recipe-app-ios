//
//  HomeViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

class HomeViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: HomeCoordinator?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Home"
        view.backgroundColor = .systemGreen
    }
}

// MARK: - Instantiation
extension HomeViewController {
    static func instantiate() -> HomeViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "HomeViewController"
        ) as? HomeViewController else {
            fatalError("HomeViewController not found in Dashboard.storyboard")
        }
        return vc
    }
}
