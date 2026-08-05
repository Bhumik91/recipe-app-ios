//
//  SearchViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 23/07/26.
//

import UIKit
import Combine

final class SearchViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var searchContainerView: UIView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var filterButton: UIButton!
    @IBOutlet private weak var filterActiveDotView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Properties
    weak var coordinator: SearchCoordinator?
    var viewModel: SearchViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var displayedItems: [SearchRecipeUIModel] = []

    // MARK: - UI State Views
    private lazy var loadingIndicatorView = createLoadingIndicator()
    private lazy var errorStateView = EmptyStateView(title: "", message: "")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureActions()
        bindViewModel()
        render(state: viewModel.searchState)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - Setup
private extension SearchViewController {
    func setupUI() {
        view.backgroundColor = UIColor(resource: .brandWhite)

        setupNavigationBar()

        searchContainerView.backgroundColor = UIColor(resource: .brandWhite)
        searchContainerView.layer.cornerRadius = 16
        searchContainerView.layer.borderWidth = 1
        searchContainerView.layer.borderColor = UIColor(resource: .brandGray2).cgColor
        searchContainerView.applyShadow(opacity: 0.08, radius: 10, offset: CGSize(width: 0, height: 4))

        searchTextField.font = UIFont(name: "Poppins-Regular", size: 14) ?? .systemFont(ofSize: 14)
        searchTextField.delegate = self

        filterButton.backgroundColor = UIColor(resource: .brandPrimary)
        filterButton.layer.cornerRadius = 16
        filterButton.setImage(UIImage(named: "ic_filter"), for: .normal)
        filterButton.tintColor = UIColor(resource: .brandWhite)
        filterButton.accessibilityLabel = "Filter"

        filterActiveDotView.backgroundColor = UIColor(resource: .brandSecondary)
        filterActiveDotView.layer.cornerRadius = 5
        filterActiveDotView.isHidden = true

        setupCollectionView()
    }

    func setupNavigationBar() {
        navigationItem.hidesBackButton = true

        let backBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "ic_arrow_backward"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        backBarButtonItem.tintColor = UIColor(resource: .brandGray1)
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.largeTitleDisplayMode = .never

        let titleLabel = UILabel()
        titleLabel.text = "Search recipes"
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 18) ?? .boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(resource: .brandGray1)
        // A bare UILabel used as titleView doesn't have a frame until sized explicitly —
        // without this the nav bar can reserve more vertical space than the text needs.
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }

    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            UINib(nibName: "SearchRecipeCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "SearchRecipeCollectionViewCell"
        )
    }

    func setupConstraints() {
        errorStateView.translatesAutoresizingMaskIntoConstraints = false
        errorStateView.isHidden = true
        view.addSubview(errorStateView)

        NSLayoutConstraint.activate([
            errorStateView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            errorStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configureActions() {
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
}

// MARK: - Actions
private extension SearchViewController {
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func filterTapped() {
        DietFilterViewController.present(from: self, selectedDiets: viewModel.selectedDiets) { [weak self] diets in
            // Dismiss the keyboard on Filter/Clear — the sheet is gone and the results are
            // about to change, so there's no reason to leave text entry focused.
            self?.searchTextField.resignFirstResponder()
            self?.viewModel.applyDietFilter(diets)
        }
    }

    @objc func searchTextChanged() {
        viewModel.onSearchQueryChanged(searchTextField.text ?? "")
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewModel.onSearchQueryChanged(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Bindings
private extension SearchViewController {
    func bindViewModel() {
        viewModel.$searchState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.render(state: state) }
            .store(in: &cancellables)

        viewModel.$recentSearches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, case .idle = viewModel.searchState else { return }
                render(state: .idle)
            }
            .store(in: &cancellables)

        viewModel.$selectedDiets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] diets in self?.filterActiveDotView.isHidden = diets.isEmpty }
            .store(in: &cancellables)
    }

    func render(state: ViewState<[SearchRecipeUIModel]>) {
        switch state {
        case .idle:
            loadingIndicatorView.stopAnimating()
            errorStateView.isHidden = true

            let recent = viewModel.recentSearches
            displayedItems = recent
            headerLabel.isHidden = recent.isEmpty
            headerLabel.text = "Recent searches"
            collectionView.isHidden = recent.isEmpty
            collectionView.reloadData()

        case .loading:
            loadingIndicatorView.startAnimating()
            errorStateView.isHidden = true
            headerLabel.isHidden = true
            collectionView.isHidden = true

        case .success(let results):
            loadingIndicatorView.stopAnimating()
            displayedItems = results

            if results.isEmpty {
                headerLabel.isHidden = true
                collectionView.isHidden = true
                errorStateView.update(title: "", message: "No results for '\(searchTextField.text ?? "")'")
                errorStateView.isHidden = false
            } else {
                errorStateView.isHidden = true
                headerLabel.isHidden = false
                headerLabel.text = "\(results.count) results found"
                collectionView.isHidden = false
                collectionView.reloadData()
            }

        case .failure(let error):
            loadingIndicatorView.stopAnimating()
            headerLabel.isHidden = true
            collectionView.isHidden = true
            errorStateView.update(title: "Something went wrong", message: error.message)
            errorStateView.isHidden = false
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        displayedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SearchRecipeCollectionViewCell",
            for: indexPath
        ) as? SearchRecipeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(recipe: displayedItems[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinator?.recipeTapped(id: displayedItems[indexPath.item].id)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // Two columns with a 16pt gutter between them — subtract it before halving so both
        // cells plus the gutter still add up to exactly the collection view's width.
        let spacing: CGFloat = 16
        let cellWidth = (collectionView.bounds.width - spacing) * 0.5
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

// MARK: - Instantiation
extension SearchViewController {
    static func instantiate(viewModel: SearchViewModel) -> SearchViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "SearchViewController"
        ) as? SearchViewController else {
            fatalError("SearchViewController not found in Dashboard.storyboard")
        }
        vc.viewModel = viewModel
        return vc
    }
}
