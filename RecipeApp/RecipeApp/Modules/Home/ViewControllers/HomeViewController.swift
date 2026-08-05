//
//  HomeViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: HomeCoordinator?
    var viewModel: HomeViewModel!
    var cancellables = Set<AnyCancellable>()
    var savedRecipes: [RecipeUIModel] = []
    // Set when the saved-recipes fetch fails, so the section shows this instead of just
    // vanishing — see HomeViewController+Bindings.
    var savedSectionErrorMessage: String?
    var exploreRecipes: [RecipeUIModel] = []
    var cuisineChips: [FilterOption] = []

    // MARK: - Sections
    // Backs numberOfSections/cellForRowAt in HomeViewController+TableView. Rebuilt whenever
    // savedRecipes flips between empty/non-empty — see HomeViewController+Bindings.
    var sections: [HomeSection] = []
    // First state update (saved or explore, whichever lands first) does a plain reloadData();
    // every update after that goes through the animated insert/delete/reload paths.
    var isInitialRender = true

    // MARK: - UI State Views
    // Full-screen loading/error overlays shown only until the initial load resolves —
    // see HomeViewController+UIState.
    lazy var loadingIndicatorView = createLoadingIndicator()
    lazy var errorStateView = EmptyStateView(title: "", message: "")

    // MARK: - IBOutlets
    @IBOutlet weak var mainTableView: UITableView!

    let headerView = HomeHeaderView()

    // redundant duplicate fetch, only refreshing on later appearances (returning to the tab).
    private var isFirstAppearance = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureGreeting()
        setupTableView()
        setupChipsCollectionView()
        setupHeaderTapHandlers()
        setupUIStateViews()
        bindViewModel()
        viewModel.loadInitial()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isFirstAppearance else {
            isFirstAppearance = false
            return
        }
        viewModel.loadSavedRecipes()
        viewModel.refreshExploreSavedStatuses()
    }

    func setupChipsCollectionView() {
        let nib = UINib(nibName: "ChipFilterCollectionViewCell", bundle: nil)
        headerView.chipsCollectionView.register(nib, forCellWithReuseIdentifier: "ChipFilterCollectionViewCell")
        headerView.chipsCollectionView.delegate = self
        headerView.chipsCollectionView.dataSource = self
    }

    private func setupHeaderTapHandlers() {
        headerView.onSearchTapped = { [weak self] in
            self?.coordinator?.searchTapped()
        }
    }

    private func configureGreeting() {
        let font = UIFont(name: "Poppins-Bold", size: 32) ?? UIFont.boldSystemFont(ofSize: 32)
        headerView.greetingLabel.attributedText = NSAttributedString(
            string: "Hello \(viewModel.userName)",
            attributes: [.font: font]
        )
    }
}

// MARK: - Instantiation
extension HomeViewController {
    static func instantiate(viewModel: HomeViewModel) -> HomeViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "HomeViewController"
        ) as? HomeViewController else {
            fatalError("HomeViewController not found in Dashboard.storyboard")
        }
        vc.viewModel = viewModel
        return vc
    }
}
