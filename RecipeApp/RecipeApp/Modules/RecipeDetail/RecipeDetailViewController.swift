//
//  RecipeDetailViewController.swift
//  RecipeApp
//

import UIKit
import Combine

final class RecipeDetailViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var saveImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var attributionLabel: UILabel!
    @IBOutlet weak var readyTimeLabel: UILabel!
    @IBOutlet weak var stepperView: CustomStepperView!
    @IBOutlet weak var itemsCountLabel: UILabel!
    @IBOutlet weak var segmentedSelector: SegmentedSelectorView!
    @IBOutlet weak var tableView: SelfSizingTableView!

    // MARK: - Constants
    enum Layout {
        static let circularButtonRadius: CGFloat = 22
        static let heroCornerRadius: CGFloat = 20
    }

    enum Section: Int {
        case ingredients
        case procedure
    }

    // MARK: - Properties
    var viewModel: RecipeDetailViewModel?
    var cancellables = Set<AnyCancellable>()
    var currentRecipe: RecipeDetailUIModel?
    private var recipeImageGradientLayer: CAGradientLayer?

    // MARK: - UI State Views
    lazy var loadingIndicatorView = createLoadingIndicator()
    lazy var errorStateView = EmptyStateView(
        title: "Something went wrong",
        message: "",
        retryTitle: "Try Again",
        onRetry: { [weak self] in self?.viewModel?.load() }
    )

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureActions()
        bindViewModel()
        viewModel?.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Disable implicit actions so the gradient's frame snaps to the card's current
        // bounds immediately, instead of interpolating (and briefly rendering at the
        // wrong size) when this layout pass lands inside another animation's transaction
        // — e.g. the segment-switch table crossfade.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        recipeImageGradientLayer?.frame = recipeImageView.bounds
        CATransaction.commit()
    }
}

// MARK: - Setup
private extension RecipeDetailViewController {
    func setupUI() {
        view.backgroundColor = UIColor(resource: .brandWhite)

        setupNavigationBar()

        recipeImageGradientLayer = recipeImageView.applyImageCardStyle(cornerRadius: Layout.heroCornerRadius, addsGradientOverlay: true)
        // Save Image Icon
        saveImageView.backgroundColor = UIColor(resource: .brandWhite)
        saveImageView.makeCircular()
        saveImageView.clipsToBounds = true 
        saveImageView.isAccessibilityElement = true
        saveImageView.accessibilityLabel = "Saved state"
        // Ste up Segment
        segmentedSelector.configure(titles: ["Ingredients", "Procedure"])
        segmentedSelector.delegate = self

        setupTableView()
    }

    func setupNavigationBar() {
        navigationItem.hidesBackButton = true

        let backBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ic_arrow_backward"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backBarButtonItem.tintColor = UIColor(resource: .brandPrimary)
        navigationItem.leftBarButtonItem = backBarButtonItem

        let menuBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ic_menu"),
            menu: nil
        )
        menuBarButtonItem.tintColor = UIColor(resource: .brandPrimary)
        navigationItem.rightBarButtonItem = menuBarButtonItem
    }

    func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        tableView.register(UINib(nibName: "IngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngredientTableViewCell")
        tableView.register(UINib(nibName: "ProcedureStepsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProcedureStepsTableViewCell")
    }

    func setupConstraints() {
        errorStateView.translatesAutoresizingMaskIntoConstraints = false
        errorStateView.isHidden = true
        view.addSubview(errorStateView)

        NSLayoutConstraint.activate([
            errorStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configureActions() {
        stepperView.onIncrement = { [weak self] in self?.viewModel?.incrementServings() }
        stepperView.onDecrement = { [weak self] in self?.viewModel?.decrementServings() }
    }
}

// MARK: - Actions
extension RecipeDetailViewController {
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    func presentShareAlert(shareURL: String) {
        guard !shareURL.isEmpty else { return }
        present(ShareRecipeAlertViewController(shareURL: shareURL), animated: true)
    }
}

// MARK: - Instantiation
extension RecipeDetailViewController {
    static func instantiate(viewModel: RecipeDetailViewModel) -> RecipeDetailViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "RecipeDetailViewController"
        ) as? RecipeDetailViewController else {
            fatalError("RecipeDetailViewController not found in Dashboard.storyboard")
        }
        vc.viewModel = viewModel
        return vc
    }
}
