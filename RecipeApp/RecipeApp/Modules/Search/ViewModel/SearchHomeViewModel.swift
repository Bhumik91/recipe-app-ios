//
//  SearchHomeViewModel.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 23/07/26.
//

import Foundation
import Combine

@MainActor
final class SearchHomeViewModel {
    // MARK: - Published State
    @Published var searchQuery: String = ""
    @Published private(set) var searchState: ViewState<[SearchRecipeUIModel]> = .idle
    @Published private(set) var recentSearches: [SearchRecipeUIModel] = []
    @Published private(set) var selectedDiets: [String] = []

    // MARK: - Dependencies
    private let recipeRepository: RecipeRepositoryProtocol
    private let recentSearchesManager: RecentSearchesStoring

    // MARK: - Search Task
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(recipeRepository: RecipeRepositoryProtocol, recentSearchesManager: RecentSearchesStoring) {
        self.recipeRepository = recipeRepository
        self.recentSearchesManager = recentSearchesManager
        self.recentSearches = recentSearchesManager.recentSearches()
        observeSearchQuery()
    }

    // Debounced so we don't fire a request on every keystroke — waits for a 300ms pause,
    // matching Android's SearchViewModel.
    private func observeSearchQuery() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self else { return }
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    searchTask?.cancel()
                    searchState = .idle
                } else {
                    performSearch(query: trimmed)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API
    func onSearchQueryChanged(_ query: String) {
        searchQuery = query
    }

    // A diet alone (no typed query) should still fetch matching dishes — only reset to
    // idle if there's neither a query nor a diet selected.
    func applyDietFilter(_ diets: [String]) {
        guard diets != selectedDiets else { return }
        selectedDiets = diets

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty || !selectedDiets.isEmpty else {
            searchTask?.cancel()
            searchState = .idle
            return
        }
        performSearch(query: query)
    }

    // MARK: - Search
    private var selectedDietQuery: String? {
        selectedDiets.isEmpty ? nil : selectedDiets.joined(separator: ",")
    }

    // Cancels any still-running search before starting a new one — a fast typist (or a
    // filter change right after typing) could otherwise let a stale request land last.
    private func performSearch(query: String) {
        searchTask?.cancel()
        searchState = .loading

        searchTask = Task {
            do {
                let recipes = try await recipeRepository.searchRecipes(query: query, diet: selectedDietQuery)
                guard !Task.isCancelled else { return }

                let results = recipes.map { $0.toSearchUIModel() }
                searchState = .success(results)

                if !results.isEmpty, !query.isEmpty {
                    recentSearchesManager.addRecentSearches(results)
                    recentSearches = recentSearchesManager.recentSearches()
                }
            } catch let error as NetworkError {
                guard !Task.isCancelled else { return }
                searchState = .failure(error)
            } catch {
                guard !Task.isCancelled else { return }
                searchState = .failure(NetworkError.unknown)
            }
        }
    }
}
