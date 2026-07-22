// DashboardTabBarController.swift
import UIKit

final class DashboardTabBarController: UITabBarController {
    // MARK: - Properties
    weak var tabBarDelegate: DashboardTabBarDelegate?
    private let customTabBar = CustomTabBar()

    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        installCustomTabBar()
        setupActions()
    }
}

// MARK: - Setup
private extension DashboardTabBarController {
    func installCustomTabBar() {
        // Replace the default UITabBar with our custom subclass using KVC.
        // WARNING: Uses private API (forKey: "tabBar") — fragile against App Store review and iOS updates.
        // Time constraint: implemented for MVP. Future scope: refactor to a custom bottom-bar container VC
        // that doesn't rely on private APIs, when core dashboard features are stable.
        setValue(customTabBar, forKey: "tabBar")
        tabBar.tintColor = UIColor(resource: .brandPrimary)
        tabBar.unselectedItemTintColor = .systemGray
    }

    func setupActions() {
        customTabBar.fabButton.addTarget(self, action: #selector(handleAddTapped), for: .touchUpInside)
    }
}

// MARK: - Actions
private extension DashboardTabBarController {
    @objc func handleAddTapped() {
        tabBarDelegate?.dashboardTabBarDidTapAdd()
    }
}
