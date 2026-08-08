//
//  ProfileViewController+Bindings.swift
//  RecipeApp
//

import UIKit

// MARK: - View Model Bindings
extension ProfileViewController {

    /// Subscribes to everything the view model publishes. Called once, from viewDidLoad.
    func bindViewModel() {
        viewModel.$profileState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.renderProfile(state) }
            .store(in: &cancellables)

        viewModel.$recipesState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                latestRecipesState = state
                // Only the Recipes tab shows this data — the other tabs keep their placeholder.
                if selectedTab == .recipes { renderTabContent() }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Profile Header
private extension ProfileViewController {

    /// Only the header is gated on this state — the tab content below has its own,
    /// so a slow or failed /auth/me never blanks out the saved recipes.
    func renderProfile(_ state: ViewState<ProfileUIModel>) {
        switch state {
        case .idle, .loading:
            loadingIndicator.startAnimating()
            scrollView.isHidden = true

        case .success(let profile):
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
            bindUser(profile)

        case .failure(let error):
            // Android keeps the screen visible on error too, so the saved-recipes tab
            // stays usable even when the profile call fails.
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
            showAlert(with: (error as? NetworkError) ?? .unknown)
        }
    }

    func bindUser(_ profile: ProfileUIModel) {
        displayNameLabel.text = profile.displayName
        userNameLabel.text = profile.userNameHandle
        emailLabel.text = profile.email
        avatarImageView.loadImage(
            from: profile.imageURL,
            placeholder: UIImage(named: "ic_default_image")
        )
    }
}

// MARK: - Tab Content
extension ProfileViewController {

    /// Renders whichever tab is selected: real data for Recipes, a placeholder for the rest.
    func renderTabContent() {
        if let placeholder = selectedTab.placeholder {
            showEmptyState(title: placeholder.title, message: placeholder.message)
            return
        }
        renderRecipesTab(latestRecipesState)
    }

    private func renderRecipesTab(_ state: ViewState<[RecipeUIModel]>) {
        switch state {
        case .success(let recipes):
            savedRecipes = recipes
            guard !recipes.isEmpty else {
                showEmptyState(
                    title: "No Saved Recipes",
                    message: "Please explore recipes to save your favorites.",
                    actionTitle: "Explore Recipes"
                )
                return
            }
            emptyStateContainer.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()

        case .failure(let error):
            savedRecipes = []
            tableView.reloadData()
            showEmptyState(title: "Something Went Wrong", message: error.message)

        case .idle, .loading:
            emptyStateContainer.isHidden = true
            tableView.isHidden = true
        }
    }

    private func showEmptyState(title: String, message: String, actionTitle: String? = nil) {
        tableView.isHidden = true
        emptyStateContainer.isHidden = false
        emptyTitleLabel.text = title
        emptyBodyLabel.text = message
        emptyActionLabel.text = actionTitle
        emptyActionLabel.isHidden = actionTitle == nil
    }
}
