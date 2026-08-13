//
//  NotificationViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 15/07/26.
//

import Combine
import UIKit

final class NotificationViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: NotificationCoordinator?
    var viewModel: NotificationViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Constants
    private enum Metric {
        static let horizontalInset: CGFloat = 24
        static let segmentHeight: CGFloat = 48
        static let segmentTopSpacing: CGFloat = 16
        static let tableTopSpacing: CGFloat = 8
        static let estimatedRowHeight: CGFloat = 80
    }

    // MARK: - UI
    private let segmentedSelectorView = SegmentedSelectorView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private lazy var emptyStateView = EmptyStateView(title: "", message: "")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Strings.screenTitle
        view.backgroundColor = .systemBackground
        setupSegmentedSelector()
        setupTableView()
        setupEmptyState()
        bindViewModel()
        viewModel.start()
    }

    // MARK: - Setup
    private func setupSegmentedSelector() {
        segmentedSelectorView.translatesAutoresizingMaskIntoConstraints = false
        segmentedSelectorView.delegate = self
        segmentedSelectorView.configure(titles: NotificationFilterTab.allCases.map(\.title))
        view.addSubview(segmentedSelectorView)

        NSLayoutConstraint.activate([
            segmentedSelectorView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Metric.segmentTopSpacing
            ),
            segmentedSelectorView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Metric.horizontalInset
            ),
            segmentedSelectorView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Metric.horizontalInset
            ),
            // The pill's corner radius derives from its height, so this constant is required.
            segmentedSelectorView.heightAnchor.constraint(equalToConstant: Metric.segmentHeight)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            NotificationLogTableViewCell.self,
            forCellReuseIdentifier: NotificationLogTableViewCell.reuseIdentifier
        )
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Metric.estimatedRowHeight
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: segmentedSelectorView.bottomAnchor,
                constant: Metric.tableTopSpacing
            ),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: tableView.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    private func render(_ state: ViewState<[NotificationLogUIModel]>) {
        switch state {
        case .idle, .loading:
            emptyStateView.isHidden = true

        case .success(let logs):
            logs.isEmpty ? showEmptyState() : showLogs()
            tableView.reloadData()

        case .failure(let error):
            // Same view, different copy.
            emptyStateView.update(title: Strings.errorTitle, message: error.message)
            emptyStateView.isHidden = false
            tableView.isHidden = true
        }
    }

    private func showEmptyState() {
        emptyStateView.update(
            title: Strings.emptyTitle,
            message: viewModel.selectedTab.emptyMessage
        )
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }

    private func showLogs() {
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }
}

// MARK: - UITableViewDataSource
extension NotificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.state.value?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let log = viewModel.state.value?[safe: indexPath.row],
            let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationLogTableViewCell.reuseIdentifier,
                for: indexPath
            ) as? NotificationLogTableViewCell
        else {
            return UITableViewCell()
        }
        cell.configure(with: log)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let log = viewModel.state.value?[safe: indexPath.row] else { return }
        coordinator?.recipeTapped(id: log.recipeId)
    }
}

// MARK: - SegmentedSelectorViewDelegate
extension NotificationViewController: SegmentedSelectorViewDelegate {
    func segmentedSelectorView(_ view: SegmentedSelectorView, didSelect index: Int) {
        guard let tab = NotificationFilterTab(rawValue: index) else { return }
        viewModel.selectTab(tab)
    }
}

// MARK: - ScrollTrackingBottomNavHost
extension NotificationViewController: ScrollTrackingBottomNavHost {
    var scrollViewDrivingBottomNav: UIScrollView { tableView }
}

// MARK: - Strings
// Kept private to the module; the project has no Localizable.strings yet.
private extension NotificationViewController {
    enum Strings {
        static let screenTitle = "Notifications"
        static let emptyTitle = "No notifications yet"
        static let errorTitle = "Something went wrong"
    }
}

// MARK: - Instantiation
extension NotificationViewController {
    static func instantiate(viewModel: NotificationViewModel) -> NotificationViewController {
        let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "NotificationViewController"
        ) as? NotificationViewController else {
            fatalError("NotificationViewController not found in Dashboard.storyboard")
        }
        vc.viewModel = viewModel
        return vc
    }
}
