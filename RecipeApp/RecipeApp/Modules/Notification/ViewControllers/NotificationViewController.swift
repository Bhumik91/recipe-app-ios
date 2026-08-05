//
//  NotificationViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit

class NotificationViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: NotificationCoordinator?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notifications"
        view.backgroundColor = .systemYellow
    }
}

// MARK: - Instantiation
extension NotificationViewController {
    static func instantiate() -> NotificationViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "NotificationViewController"
        ) as? NotificationViewController else {
            fatalError("NotificationViewController not found in Dashboard.storyboard")
        }
        return vc
    }
}
