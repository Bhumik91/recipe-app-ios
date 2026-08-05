//
//  FilterOption.swift
//  RecipeApp
//

struct FilterOption {
    let label: String
    var isSelected: Bool = false
}

extension Array where Element == String {
    func toFilterOptions(selected: Set<String> = []) -> [FilterOption] {
        map { FilterOption(label: $0, isSelected: selected.contains($0)) }
    }
}

// Cuisine chip selection state for the Home screen. Home has no diet filter of its own —
// that's Search's (SearchHomeViewModel.selectedDiets), a separate, unrelated state.
struct FilterState {
    var cuisineChips: [FilterOption] = [FilterOption(label: "All", isSelected: true)]
    var selectedCuisines: Set<String> = []
}
