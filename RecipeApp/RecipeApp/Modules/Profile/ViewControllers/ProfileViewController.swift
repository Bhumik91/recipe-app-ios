//
//  ProfileViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit
import Combine

/// The signed-in user's profile: details header, segmented selector, and logout.
///
/// Split across three files:
/// - this one     : properties, lifecycle, one-time setup, logout, hide/show title bar on scroll
/// - `+TableView` : saved-recipe rows and segment selection
/// - `+Bindings`  : view model subscriptions and screen states
final class ProfileViewController: UIViewController {

    // MARK: - Properties
    weak var coordinator: ProfileCoordinator?
    var viewModel: ProfileViewModel!
    var cancellables = Set<AnyCancellable>()

    // MARK: - Scroll
    // Drives the title-bar hide/show below.
    private let navBarVisibilityTracker = ScrollVisibilityTracker()

    /// Latest saved-recipes result, kept so switching back to the Recipes tab can
    /// re-render without re-fetching — mirrors Android's `latestRecipesState`.
    var latestRecipesState: ViewState<[RecipeUIModel]> = .idle
    var savedRecipes: [RecipeUIModel] = []
    var selectedTab: ProfileTab = .recipes

    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var segmentedSelector: SegmentedSelectorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateContainer: UIView!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyBodyLabel: UILabel!
    @IBOutlet weak var emptyActionLabel: UILabel!

    // MARK: - UI
    // Built in code, not the storyboard — an IB indicator that starts neither hidden nor
    // animating trips a build warning.
    lazy var loadingIndicator = createLoadingIndicator()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        setupNavigationBar()
        setupSegmentedSelector()
        setupTableView()
        setupScrollView()
        setupEmptyStateAction()
        bindViewModel()
        viewModel.loadProfile()
    }

    // Re-fetched on every appearance, not just the first: a recipe saved or unsaved on
    // another tab should be reflected here on return. Matches Android's onResume().
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navBarVisibilityTracker.forceShow()
        setNavigationBar(hidden: false, animated: animated)
        viewModel.loadSavedRecipes()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Scroll may have left the bar hidden, and the next screen shares this
        // navigation controller — hand it back a visible bar.
        setNavigationBar(hidden: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
    }
}

// MARK: - Setup
private extension ProfileViewController {

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
        // Set all three, or the bar turns transparent when the content is at the top.
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance

        let logoutButton = UIBarButtonItem(
            image: UIImage(named: "ic_logout"),
            style: .plain,
            target: self,
            action: #selector(logoutTapped)
        )
        logoutButton.tintColor = UIColor(resource: .brandBlack)
        logoutButton.accessibilityLabel = "Logout"
        navigationItem.rightBarButtonItem = logoutButton
    }

    func setupSegmentedSelector() {
        segmentedSelector.configure(titles: ProfileTab.allCases.map(\.title))
        segmentedSelector.delegate = self
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

    // `tableView` has scrolling disabled and is sized to its content — `scrollView` is
    // the one actually being dragged, so it's what drives the title-bar visibility.
    func setupScrollView() {
        scrollView.delegate = self
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

    @objc func logoutTapped() {
        let alert = LogoutConfirmationViewController()
        alert.onConfirm = { [weak self] in
            guard let self else { return }
            viewModel.logout()
            coordinator?.didLogout()
        }
        present(alert, animated: true)
    }
}

// MARK: - Hide Title Bar While Scrolling
extension ProfileViewController: UIScrollViewDelegate {

    /// Hides the title bar as the user reads down the profile, brings it back the
    /// instant they scroll back up — same tracker-driven behaviour as Saved Recipes.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let hidden = navBarVisibilityTracker.handle(scrollView: scrollView) else { return }
        setNavigationBar(hidden: hidden)
    }
}

// MARK: - ScrollTrackingBottomNavHost
extension ProfileViewController: ScrollTrackingBottomNavHost {
    var scrollViewDrivingBottomNav: UIScrollView { scrollView }
}

// MARK: - Instantiation
extension ProfileViewController {

    static func instantiate(viewModel: ProfileViewModel) -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "ProfileViewController"
        ) as? ProfileViewController else {
            fatalError("ProfileViewController not found in Dashboard.storyboard")
        }
        vc.viewModel = viewModel
        return vc
    }
}
