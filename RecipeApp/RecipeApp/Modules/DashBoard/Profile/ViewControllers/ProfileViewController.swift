//
//  ProfileViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

class ProfileViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: ProfileCoordinator?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Profile"
        view.backgroundColor = .systemPurple
    }
}

// MARK: - Instantiation
extension ProfileViewController {
    static func instantiate() -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "ProfileViewController"
        ) as? ProfileViewController else {
            fatalError("ProfileViewController not found in Dashboard.storyboard")
        }
        return vc
    }
}
