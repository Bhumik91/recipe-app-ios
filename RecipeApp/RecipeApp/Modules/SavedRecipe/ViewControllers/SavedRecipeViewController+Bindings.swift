//
//  SavedRecipeViewController+Bindings.swift
//  RecipeApp
//

import UIKit

// MARK: - View Model Bindings
extension SavedRecipeViewController {

    /// Subscribes to everything the view model publishes. Called once, from viewDidLoad.
    func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.render(state) }
            .store(in: &cancellables)

        viewModel.$recipes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.reloadTable() }
            .store(in: &cancellables)

        viewModel.snackbarEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.showRemovedSnackbar() }
            .store(in: &cancellables)
    }
}

// MARK: - Screen States
private extension SavedRecipeViewController {

    func render(_ state: ViewState<[RecipeUIModel]>) {
        switch state {
        case .idle:
            showLoading(false)
            errorContainerView.isHidden = true
            emptyStateContainer.isHidden = true
            tableView.isHidden = false

        case .success(let recipes):
            showLoading(false)
            errorContainerView.isHidden = true
            emptyStateContainer.isHidden = !recipes.isEmpty
            tableView.isHidden = recipes.isEmpty

        case .loading:
            showLoading(true)
            errorContainerView.isHidden = true
            emptyStateContainer.isHidden = true
            tableView.isHidden = true

        case .failure(let error):
            showLoading(false)
            errorMessageLabel.text = error.message
            errorContainerView.isHidden = false
            emptyStateContainer.isHidden = true
            tableView.isHidden = true
        }
    }

    func showLoading(_ isLoading: Bool) {
        loadingIndicator.isHidden = !isLoading
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    func reloadTable() {
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }

    func showRemovedSnackbar() {
        showUndoSnackbar(message: "Recipe removed from saved") { [weak self] in
            self?.viewModel.undoRemoveRecipe()
        }
    }
}
