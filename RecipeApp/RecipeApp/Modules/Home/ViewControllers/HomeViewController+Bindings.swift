//
//  HomeViewController+Bindings.swift
//  RecipeApp
//

import UIKit

// MARK: - ViewModel Binding & Section Diffing
// Turns HomeViewModel's per-list state into animated table updates instead of full
// reloads — see HomeSection for the section layout this drives.
extension HomeViewController {
    func bindViewModel() {
        viewModel.$savedState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .success(let recipes):
                    savedSectionErrorMessage = nil
                    applySavedRecipes(recipes)
                case .failure(let error):
                    savedSectionErrorMessage = error.message
                    applySavedRecipes([])
                case .idle, .loading:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.$exploreState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self, case .success(let recipes) = state else { return }
                applyExploreRecipes(recipes)
            }
            .store(in: &cancellables)

        viewModel.$filterState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                cuisineChips = state.cuisineChips
                headerView.chipsCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    func buildSections() -> [HomeSection] {
        var sections: [HomeSection] = [.header]
        if !savedRecipes.isEmpty {
            sections += [.savedHeader, .savedRecipes]
        } else if savedSectionErrorMessage != nil {
            // Row-less: just the header, repurposed to show the error text.
            sections += [.savedHeader]
        }
        sections += [.exploreHeader, .exploreRecipes]
        return sections
    }

    // Saved section can appear/disappear (empty <-> non-empty) or its header can flip
    // between the title and an error message — any of that changes the section list, so
    // just reload. Only the common case (section list unchanged) skips straight to an
    // in-place update.
    private func applySavedRecipes(_ recipes: [RecipeUIModel]) {
        savedRecipes = recipes

        guard !isInitialRender else {
            sections = buildSections()
            mainTableView.reloadData()
            isInitialRender = false
            return
        }

        let newSections = buildSections()
        guard newSections == sections else {
            sections = newSections
            mainTableView.reloadData()
            return
        }

        if !recipes.isEmpty {
            reloadSavedRecipesCellInPlace()
        }
    }

    // The saved section's row count never changes (it's always exactly one row hosting a
    // horizontal collection) — so a saved-count change with the section already present
    // just hands the fresh array to the visible cell and lets its own diffable data
    // source animate the collection, with no table-level operation at all.
    private func reloadSavedRecipesCellInPlace() {
        guard let sectionIndex = sections.firstIndex(of: .savedRecipes) else { return }
        let indexPath = IndexPath(row: 0, section: sectionIndex)
        guard let cell = mainTableView.cellForRow(at: indexPath) as? SavedRecipesTableViewCell else { return }
        cell.configure(recipes: savedRecipes)
    }

    // exploreRecipes never changes section count/position; only its own row count and
    // contents change, so this only ever touches rows within the existing explore section.
    private func applyExploreRecipes(_ recipes: [RecipeUIModel]) {
        guard !isInitialRender else {
            exploreRecipes = recipes
            sections = buildSections()
            mainTableView.reloadData()
            isInitialRender = false
            return
        }

        let old = exploreRecipes
        exploreRecipes = recipes
        guard let sectionIndex = sections.firstIndex(of: .exploreRecipes) else { return }

        // Same items in the same order, only isSaved flags differ — a bookmark toggle.
        if old.count == recipes.count, old.map(\.id) == recipes.map(\.id) {
            let changedRows = (0..<recipes.count).filter { old[$0] != recipes[$0] }
            guard !changedRows.isEmpty else { return }
            mainTableView.reloadRows(at: changedRows.map { IndexPath(row: $0, section: sectionIndex) }, with: .none)
            return
        }

        // The old list is an unchanged prefix of the new one — a pagination append.
        if recipes.count > old.count, Array(recipes.prefix(old.count)) == old {
            let newRows = (old.count..<recipes.count).map { IndexPath(row: $0, section: sectionIndex) }
            mainTableView.insertRows(at: newRows, with: .automatic)
            return
        }

        // Anything else (filter change, full replace) is a legitimate bulk refresh.
        mainTableView.reloadSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
}
