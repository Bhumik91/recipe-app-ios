//
//  HomeViewModel.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//
import Combine

@MainActor
final class HomeViewModel {
    // MARK: - Published State
    @Published private(set) var exploreState: ViewState<[RecipeUIModel]> = .idle
    @Published private(set) var savedState: ViewState<[RecipeUIModel]> = .idle
    @Published private(set) var filterState = FilterState()
    // First-load state, driven by exploreState only — saved recipes are secondary.
    @Published private(set) var screenState: ViewState<Void> = .idle

    // MARK: - Dependencies
    private let recipeRepository: RecipeRepositoryProtocol
    private let sessionManager: SessionManaging
    private let cuisineOptions: [String]

    // MARK: - Pagination State
    // Explore-list pagination bookkeeping. Plain vars (not @Published) since they're pure
    // implementation detail of loadNextExplorePage and never rendered directly.
    private var currentOffset = 0
    private var isLastPage = false
    private var isLoadingMore = false
    private var exploreItems: [RecipeUIModel] = []
    private var explorePageTask: Task<Void, Never>?

    private var hasCompletedInitialLoad = false
    private var cancellables = Set<AnyCancellable>()

    var userName: String {
        sessionManager.userName ?? "there"
    }

    // MARK: - Initialization
    init(recipeRepository: RecipeRepositoryProtocol, sessionManager: SessionManaging) {
        self.recipeRepository = recipeRepository
        self.sessionManager = sessionManager
        self.cuisineOptions = recipeRepository.getCuisines()
        filterState.cuisineChips = Self.buildCuisineChips(from: cuisineOptions, selected: [])
        setupScreenState()
    }

    private func setupScreenState() {
        $exploreState
            .sink { [weak self] explore in
                guard let self, !hasCompletedInitialLoad else { return }
                switch explore {
                case .failure(let error):
                    screenState = .failure(error)
                case .success:
                    screenState = .success(())
                    hasCompletedInitialLoad = true
                case .idle, .loading:
                    screenState = .loading
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading
    // Resets pagination and re-fetches both lists from page 0 — used on first load and
    // whenever the cuisine/diet filter selection changes.
    func loadInitial() {
        explorePageTask?.cancel()
        isLoadingMore = false
        currentOffset = 0
        isLastPage = false
        exploreItems = []
        loadNextExplorePage()
        loadSavedRecipes()
    }

    // MARK: - Filtering
    // Multi-select cuisine toggle: "All" clears the selection, a selected cuisine deselects, otherwise it's added.
    func toggleCuisineFilter(_ cuisine: String) {
        var newSelection = filterState.selectedCuisines
        if cuisine == "All" {
            newSelection = []
        } else if newSelection.contains(cuisine) {
            newSelection.remove(cuisine)
        } else {
            newSelection.insert(cuisine)
        }
        guard newSelection != filterState.selectedCuisines else { return }
        filterState.selectedCuisines = newSelection
        filterState.cuisineChips = Self.buildCuisineChips(from: cuisineOptions, selected: newSelection)
        loadInitial()
    }

    private static func buildCuisineChips(from cuisines: [String], selected: Set<String>) -> [FilterOption] {
        var chips = [FilterOption(label: "All", isSelected: selected.isEmpty)]
        chips += cuisines.filter { $0 != "All" }.toFilterOptions(selected: selected)
        return chips
    }

    private var selectedCuisineQuery: String? {
        filterState.selectedCuisines.isEmpty ? nil : filterState.selectedCuisines.joined(separator: ",")
    }

    // Fetches the next page of explore recipes for the current filter selection, appending
    // to the running list. Guarded by isLoadingMore/isLastPage so pagination-scroll triggers
    // (see HomeViewController+TableView's scrollViewDidScroll) can't fire overlapping requests.
    func loadNextExplorePage() {
        guard !isLoadingMore, !isLastPage else { return }
        isLoadingMore = true
        if exploreItems.isEmpty {
            exploreState = .loading
        }
        explorePageTask = Task {
            do {
                // TODO: thread the diet filter selection through once the Filter screen ships.
                let page = try await recipeRepository.fetchRecipes(cuisine: selectedCuisineQuery, diet: nil, offset: currentOffset)
                guard !Task.isCancelled else { return }
                exploreItems += page.results
                currentOffset += page.results.count
                isLastPage = currentOffset >= page.totalResults
                exploreState = .success(exploreItems)
            } catch let error as NetworkError {
                guard !Task.isCancelled else { return }
                exploreState = .failure(error)
            } catch {
                guard !Task.isCancelled else { return }
                exploreState = .failure(NetworkError.unknown)
            }
            isLoadingMore = false
        }
    }

    func loadSavedRecipes() {
        savedState = .loading
        Task {
            do {
                let recipes = try await recipeRepository.fetchSavedRecipes()
                savedState = .success(recipes)
            } catch let error as NetworkError {
                savedState = .failure(error)
            } catch {
                savedState = .failure(NetworkError.unknown)
            }
        }
    }

    // MARK: - Bookmark Management
    // Flips the saved flag locally and patches the saved list from data already in hand,
    // instead of refetching — avoids a flicker/reload on every bookmark tap.
    func toggleSaved(dishId: Int) {
        recipeRepository.toggleSavedRecipe(recipeId: dishId)

        if let index = exploreItems.firstIndex(where: { $0.id == dishId }) {
            exploreItems[index].isSaved.toggle()
            exploreState = .success(exploreItems)
        }

        updateSavedRecipesLocally(dishId: dishId)
    }

    // Removes the item if it was saved, or appends it (using the explore-list copy we
    // already have) if it just got saved. Falls back to a refetch if we have neither.
    private func updateSavedRecipesLocally(dishId: Int) {
        guard case .success(var recipes) = savedState else {
            loadSavedRecipes()
            return
        }

        if let index = recipes.firstIndex(where: { $0.id == dishId }) {
            recipes.remove(at: index)
        } else if let recipe = exploreItems.first(where: { $0.id == dishId }) {
            recipes.append(recipe)
        } else {
            loadSavedRecipes()
            return
        }

        savedState = .success(recipes)
    }

    // TODO: wire up once the Search screen ships (calls recipeRepository.searchRecipes(query:diet:)).
}
