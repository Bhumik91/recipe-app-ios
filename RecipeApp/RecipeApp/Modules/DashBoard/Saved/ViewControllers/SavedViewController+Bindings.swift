//
//  SavedViewController+Bindings.swift
//  RecipeApp
//

import UIKit

// MARK: - View Model Bindings
extension SavedViewController {

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
private extension SavedViewController {

    func render(_ state: ViewState<[RecipeUIModel]>) {
        switch state {
        case .idle, .success:
            showLoading(false)
            errorContainerView.isHidden = true
            tableView.isHidden = false

        case .loading:
            showLoading(true)
            errorContainerView.isHidden = true
            tableView.isHidden = true

        case .failure(let error):
            showLoading(false)
            errorMessageLabel.text = error.message
            errorContainerView.isHidden = false
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
