//
//  SavedRecipeViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit
import Combine

/// Shows the user's saved recipes. Swipe a row left to remove it (with undo).
///
/// Split across three files:
/// - this one          : properties, lifecycle, one-time setup
/// - `+TableView`      : rows, swipe-to-delete, hide/show nav bar on scroll
/// - `+Bindings`       : view model subscriptions and loading/error states
final class SavedRecipeViewController: UIViewController {

    // MARK: - Properties
    weak var coordinator: SavedRecipeCoordinator?
    var viewModel: SavedRecipeViewModel!
    var cancellables = Set<AnyCancellable>()

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorContainerView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var retryLabel: UILabel!
    @IBOutlet weak var emptyStateContainer: UIView!
    @IBOutlet weak var emptyActionLabel: UILabel!

    // MARK: - UI
    lazy var loadingIndicator = createLoadingIndicator()

    // MARK: - Scroll
    // Drives the nav-bar hide/show in +TableView.
    let navBarVisibilityTracker = ScrollVisibilityTracker()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Saved"
        setupNavigationBar()
        setupTableView()
        setupRetryTap()
        setupEmptyStateAction()
        bindViewModel()
        viewModel.loadRecipes()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBarVisibilityTracker.forceShow()
        setNavigationBar(hidden: false)
        viewModel.loadRecipes()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Scroll may have left the bar hidden, and the next screen shares this
        // navigation controller — hand it back a visible bar.
        setNavigationBar(hidden: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyTopInsetOnce()
    }
}

// MARK: - Setup
private extension SavedRecipeViewController {

    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = nil
        appearance.titleTextAttributes = [
            .font: UIFont(name: "Poppins-SemiBold", size: 18) ?? .boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.label
        ]

        // Set all three, or the bar turns transparent when the list is at the top.
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderTopPadding = 0
        tableView.register(
            UINib(nibName: SavedRecipeTableViewCell.reuseID, bundle: nil),
            forCellReuseIdentifier: SavedRecipeTableViewCell.reuseID
        )
    }

    func setupRetryTap() {
        retryLabel.isUserInteractionEnabled = true
        retryLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(retryTapped))
        )
    }

    @objc func retryTapped() {
        viewModel.loadRecipes()
    }

    func setupEmptyStateAction() {
        emptyActionLabel.isUserInteractionEnabled = true
        emptyActionLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(exploreRecipesTapped))
        )
    }

    @objc func exploreRecipesTapped() {
        coordinator?.exploreRecipesTapped()
    }

    /// The table starts at the very top of the screen, so it needs a top inset to clear
    /// the status bar and nav bar. We set it once ourselves rather than letting UIKit
    /// adjust it automatically — UIKit would redo it every time the nav bar hides,
    /// and changing insets mid-scroll interrupts the user's drag.
    func applyTopInsetOnce() {
        guard tableView.contentInset.top == 0 else { return }
        tableView.contentInset.top = view.safeAreaInsets.top
        tableView.verticalScrollIndicatorInsets.top = view.safeAreaInsets.top
    }
}

// MARK: - Instantiation
extension SavedRecipeViewController {

    static func instantiate(viewModel: SavedRecipeViewModel) -> SavedRecipeViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "SavedRecipeViewController"
        ) as? SavedRecipeViewController else {
            fatalError("SavedRecipeViewController not found in Dashboard.storyboard")
        }
        vc.viewModel = viewModel
        return vc
    }
}
