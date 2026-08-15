//
//  HomeHeaderView.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 16/07/26.
//

import UIKit

final class HomeHeaderView: UIView {
    // MARK: - IBOutlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var searchContainerView: HighlightableControl!
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var chipsCollectionView: UICollectionView!

    /// The search field is display-only — tapping it should navigate to a dedicated
    /// search screen rather than open the keyboard in place.
    var onSearchTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("HomeHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        configureUI()
    }
    
    private func configureUI() {
        configureSearchContainer()
        configureTapHandlers()
    }

    private func configureSearchContainer() {
        guard let container = searchContainerView else { return }
        // Implementing styling for border
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor(named: "BrandGray2")?.cgColor
        container.backgroundColor = UIColor(named: "BrandWhite") ?? .white

        // Implementing Shadow and radius
        applyShadow(to: container)

        // Set placeholder
        searchTextField.placeholder = "Search recipe"
    }

    private func configureTapHandlers() {
        // The search field only displays the placeholder — the whole bar acts as one tap
        // target. It's a HighlightableControl (not a plain UIView), so this also gets
        // the same press-down dimming feedback a UIButton has built in.
        searchContainerView.addTarget(self, action: #selector(searchContainerTapped), for: .touchUpInside)
    }

    @objc private func searchContainerTapped() {
        onSearchTapped?()
    }

    private func applyShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
    }
}
