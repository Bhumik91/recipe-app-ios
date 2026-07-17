//
//  DashboardViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 13/07/26.
//

import UIKit

class DashboardViewController: UIViewController {
    // MARK: - Properties
    weak var coordinatorDelegate: DashboardCoordinator?
    var userName: String?
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = "Welcome, \(userName ?? "User")!"
    }
    
    // MARK: - Actions
    @IBAction func logoutTapped(_ sender: UIButton) {
        coordinatorDelegate?.logoutTapped()
    }
}
