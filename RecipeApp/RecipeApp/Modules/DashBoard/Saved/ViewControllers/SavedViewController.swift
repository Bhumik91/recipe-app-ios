//
//  SavedViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

class SavedViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: SavedCoordinator?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Saved"
        view.backgroundColor = .systemBlue
    }
}

// MARK: - Instantiation
extension SavedViewController {
    static func instantiate() -> SavedViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "SavedViewController"
        ) as? SavedViewController else {
            fatalError("SavedViewController not found in Dashboard.storyboard")
        }
        return vc
    }
}
