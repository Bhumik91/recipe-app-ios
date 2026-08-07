//
//  NotificationViewModel.swift
//  RecipeApp
//

import Combine
import Foundation

/// Drives the Notification screen from the log stream.
/// Subscribes once and filters client-side, so switching tabs never refetches.
@MainActor
final class NotificationViewModel {

    // MARK: - Published State
    @Published private(set) var state: ViewState<[NotificationLogUIModel]> = .idle
    @Published private(set) var selectedTab: NotificationFilterTab = .all

    // MARK: - Dependencies
    private let notificationLogStore: NotificationLogStoring

    // MARK: - Private State
    private var allLogs: [NotificationLogUIModel] = []
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(notificationLogStore: NotificationLogStoring) {
        self.notificationLogStore = notificationLogStore
    }

    // MARK: - Loading
    func start() {
        guard cancellables.isEmpty else { return }
        state = .loading

        notificationLogStore.observeLogs()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] logs in
                guard let self else { return }
                self.allLogs = logs
                self.publishFilteredLogs()
            }
            .store(in: &cancellables)
    }

    // MARK: - Filtering
    func selectTab(_ tab: NotificationFilterTab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        publishFilteredLogs()
    }

    /// Applies the active tab to the rows already in memory.
    private func publishFilteredLogs() {
        state = .success(filtered(allLogs, by: selectedTab))
    }

    private func filtered(
        _ logs: [NotificationLogUIModel],
        by tab: NotificationFilterTab
    ) -> [NotificationLogUIModel] {
        switch tab {
        case .all: return logs
        case .saved: return logs.filter { $0.action == .saved }
        case .removed: return logs.filter { $0.action == .removed }
        }
    }
}
