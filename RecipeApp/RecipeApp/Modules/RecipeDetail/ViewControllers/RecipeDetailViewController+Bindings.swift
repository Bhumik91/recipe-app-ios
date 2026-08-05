//
//  RecipeDetailViewController+Bindings.swift
//  RecipeApp
//

import UIKit
import Combine

// MARK: - Bindings
extension RecipeDetailViewController {
    func bindViewModel() {
        guard let viewModel else { return }

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in self?.render(state) }
            .store(in: &cancellables)

        viewModel.$targetServings
            .receive(on: DispatchQueue.main)
            .sink { [weak self] servings in self?.updateServings(servings) }
            .store(in: &cancellables)
    }

    func render(_ state: ViewState<RecipeDetailUIModel>) {
        switch state {
        case .idle:
            break

        case .loading:
            loadingIndicatorView.startAnimating()
            errorStateView.isHidden = true
            scrollView.isHidden = true

        case .success(let recipe):
            loadingIndicatorView.stopAnimating()
            errorStateView.isHidden = true
            scrollView.isHidden = false
            bind(recipe: recipe)

        case .failure(let error):
            loadingIndicatorView.stopAnimating()
            scrollView.isHidden = true
            errorStateView.update(
                title: "Something went wrong",
                message: error.message,
                retryTitle: error.isRetryable ? "Try Again" : nil,
                onRetry: { [weak self] in self?.viewModel?.load() }
            )
            errorStateView.isHidden = false
        }
    }

    func bind(recipe: RecipeDetailUIModel) {
        currentRecipe = recipe

        titleLabel.text = recipe.title

        if let attribution = recipe.attribution, !attribution.isEmpty {
            attributionLabel.isHidden = false
            attributionLabel.text = "By \(attribution)"
        } else {
            attributionLabel.isHidden = true
        }

        readyTimeLabel.text = "\(recipe.readyInMinutes) mins"
        recipeImageView.loadImage(from: recipe.imageURL, placeholder: UIImage(named: "ic_default_image"))
        recipeImageView.accessibilityLabel = recipe.title

        updateSaveIndicator(isSaved: recipe.isSaved)
        updateMoreMenu(recipe: recipe)
        updateItemsCount()
        updateEmptyState(recipe: recipe)
        tableView.reloadData()
    }

    func updateServings(_ servings: Int) {
        stepperView.configure(servings: servings)

        guard currentRecipe != nil, isIngredientsSelected else { return }
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve) {
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            }
        }
    }

    func updateSaveIndicator(isSaved: Bool) {
        saveImageView.tintColor = isSaved ? UIColor(resource: .brandPrimary) : UIColor(resource: .brandGray2)
    }

    func updateMoreMenu(recipe: RecipeDetailUIModel) {
        let shareImage = UIImage(named: "ic_share")?.withTintColor(UIColor(resource: .brandGray3))
        let shareAction = UIAction(title: "Share", image: shareImage) { [weak self] _ in
            self?.presentShareAlert(shareURL: recipe.shareURL ?? "")
        }

        let saveTitle = recipe.isSaved ? "Remove from saved" : "Save recipe"
        let saveTint = recipe.isSaved ? UIColor(resource: .brandPrimary) : UIColor(resource: .brandGray2)
        let saveIcon = UIImage(named: "ic_saved_outlined")?.withTintColor(saveTint, renderingMode: .alwaysOriginal)
        let saveAction = UIAction(title: saveTitle, image: saveIcon) { [weak self] _ in
            self?.viewModel?.toggleSaved()
        }

        navigationItem.rightBarButtonItem?.menu = UIMenu(children: [shareAction, saveAction])
    }

    func updateItemsCount() {
        guard let recipe = currentRecipe else { return }
        itemsCountLabel.text = isIngredientsSelected
            ? "\(recipe.ingredients.count) ingredients"
            : "\(recipe.instructionSteps.count) steps"
    }

    func updateEmptyState(recipe: RecipeDetailUIModel) {
        guard !isIngredientsSelected, recipe.instructionSteps.isEmpty else {
            tableView.backgroundView = nil
            return
        }
        tableView.backgroundView = EmptyStateView(
            title: "No instructions yet",
            message: "This recipe doesn't have step-by-step instructions available."
        )
    }

    var isIngredientsSelected: Bool {
        segmentedSelector.selectedIndex == Section.ingredients.rawValue
    }
}

// MARK: - SegmentedSelectorViewDelegate
extension RecipeDetailViewController: SegmentedSelectorViewDelegate {
    func segmentedSelectorView(_ view: SegmentedSelectorView, didSelect index: Int) {
        updateItemsCount()
        if let recipe = currentRecipe {
            updateEmptyState(recipe: recipe)
        }
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve) {
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RecipeDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipe = currentRecipe else { return 0 }
        return isIngredientsSelected ? recipe.ingredients.count : recipe.instructionSteps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipe = currentRecipe else { return UITableViewCell() }

        if isIngredientsSelected {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell", for: indexPath) as? IngredientTableViewCell else {
                return UITableViewCell()
            }
            let ingredient = recipe.ingredients[indexPath.row]
            cell.configure(
                ingredient: ingredient,
                baseServings: recipe.servings,
                targetServings: viewModel?.targetServings ?? recipe.servings
            )
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProcedureStepsTableViewCell", for: indexPath) as? ProcedureStepsTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(step: recipe.instructionSteps[indexPath.row])
            return cell
        }
    }
}
