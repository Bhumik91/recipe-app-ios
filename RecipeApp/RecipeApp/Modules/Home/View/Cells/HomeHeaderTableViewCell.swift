//
//  HomeHeaderTableViewCell.swift
//  RecipeApp
//

import UIKit

/// Hosts the greeting/search/filter-chips `HomeHeaderView` as a normal, self-sizing
/// section-0 row instead of `UITableView.tableHeaderView` — tableHeaderView doesn't
/// participate in automatic row-height layout, which was the source of the header
/// briefly rendering blank/wrong-sized on first load.
final class HomeHeaderTableViewCell: UITableViewCell {
    private var containedView: UIView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func embed(_ view: UIView) {
        guard containedView !== view else { return }
        containedView?.removeFromSuperview()
        containedView = view

        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
