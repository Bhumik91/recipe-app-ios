//
//  HomeViewController+UIState.swift
//  RecipeApp
//

import UIKit

// MARK: - Whole-Screen Loading/Error State
// Drives HomeViewModel.screenState only — the per-list ViewState<[RecipeUIModel]> for
// explore/saved is handled separately in HomeViewController+Bindings and never touches
// these views, so a bookmark toggle or pagination fetch can't re-trigger a full-screen spinner.
extension HomeViewController {
    func setupUIStateViews() {

        errorStateView.isHidden = true
        errorStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorStateView)

        NSLayoutConstraint.activate([
            errorStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        viewModel.$screenState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                applyScreenState(state)
            }
            .store(in: &cancellables)
    }

    private func applyScreenState(_ state: ViewState<Void>) {
        switch state {
        case .idle:
            loadingIndicatorView.stopAnimating()
            errorStateView.isHidden = true
            mainTableView.isHidden = false

        case .loading:
            loadingIndicatorView.startAnimating()
            errorStateView.isHidden = true
            mainTableView.isHidden = true

        case .success:
            loadingIndicatorView.stopAnimating()
            errorStateView.isHidden = true
            mainTableView.isHidden = false

        case .failure(let error):
            loadingIndicatorView.stopAnimating()
            mainTableView.isHidden = true
            showError(error)
        }
    }

    // Surfaces the real underlying error (title/message already differ per NetworkError
    // case) instead of one generic string, and only offers "Try Again" when re-fetching
    // could plausibly help — see DisplayableError.isRetryable.
    private func showError(_ error: DisplayableError) {
        let title = (error as? NetworkError)?.title ?? "Something Went Wrong"
        errorStateView.update(
            title: title,
            message: error.message,
            retryTitle: error.isRetryable ? "Try Again" : nil,
            onRetry: { [weak self] in
                self?.viewModel.loadInitial()
            }
        )
        errorStateView.isHidden = false
    }
}
