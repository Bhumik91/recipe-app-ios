//
//  DietFilterViewController.swift
//  RecipeApp
//

import UIKit

/// Multi-select diet filter sheet, presented as a native bottom sheet. Selection is local
/// until "Filter"/"Clear" is tapped, mirroring Android's DietFilterBottomSheet.
final class DietFilterViewController: UIViewController {
    // MARK: - Views
    private let titleLabel = UILabel()
    private let clearButton = UIButton(type: .system)
    private let dietLabel = UILabel()
    private let collectionView: UICollectionView
    private let applyButton = UIButton(type: .system)

    // MARK: - State
    private var chips: [FilterOption]
    private let onApply: ([String]) -> Void

    // MARK: - Init
    init(selectedDiets: [String], onApply: @escaping ([String]) -> Void) {
        self.chips = DietOptions.diets.toFilterOptions(selected: Set(selectedDiets))
        self.onApply = onApply

        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureActions()
    }
}

// MARK: - Setup
private extension DietFilterViewController {
    func setupUI() {
        view.backgroundColor = UIColor(resource: .brandWhite)

        titleLabel.text = "Filter Search"
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 18) ?? .boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(resource: .brandGray1)
        titleLabel.textAlignment = .center

        clearButton.setTitle("Clear", for: .normal)
        clearButton.titleLabel?.font = UIFont(name: "Poppins-Medium", size: 14) ?? .systemFont(ofSize: 14)
        clearButton.setTitleColor(UIColor(resource: .brandPrimary), for: .normal)

        dietLabel.text = "Diet"
        dietLabel.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? .boldSystemFont(ofSize: 16)
        dietLabel.textColor = UIColor(resource: .brandGray1)

        setupCollectionView()

        applyButton.setTitle("Filter", for: .normal)
        applyButton.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16) ?? .boldSystemFont(ofSize: 16)
        applyButton.setTitleColor(UIColor(resource: .brandWhite), for: .normal)
        applyButton.backgroundColor = UIColor(resource: .brandPrimary)
        applyButton.layer.cornerRadius = 20

        for view in [titleLabel, clearButton, dietLabel, collectionView, applyButton] {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
    }

    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            UINib(nibName: "ChipFilterCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ChipFilterCollectionViewCell"
        )
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            clearButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            dietLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            dietLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            collectionView.topAnchor.constraint(equalTo: dietLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            collectionView.bottomAnchor.constraint(equalTo: applyButton.topAnchor, constant: -32),

            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            applyButton.heightAnchor.constraint(equalToConstant: 52),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    func configureActions() {
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
    }
}

// MARK: - Actions
private extension DietFilterViewController {
    @objc func clearTapped() {
        onApply([])
        dismiss(animated: true)
    }

    @objc func applyTapped() {
        onApply(chips.filter(\.isSelected).map(\.label))
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension DietFilterViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chips.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ChipFilterCollectionViewCell",
            for: indexPath
        ) as? ChipFilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        let chip = chips[indexPath.item]
        cell.configure(title: chip.label, isSelected: chip.isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        chips[indexPath.item].isSelected.toggle()
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let title = chips[indexPath.item].label
        let font = UIFont(name: "Poppins-Medium", size: 16) ?? .systemFont(ofSize: 16)
        let width = title.size(withAttributes: [.font: font]).width + 32
        return CGSize(width: max(width, 60), height: 44)
    }
}

// MARK: - Presentation
extension DietFilterViewController {
    static func present(from presenter: UIViewController, selectedDiets: [String], onApply: @escaping ([String]) -> Void) {
        let filterVC = DietFilterViewController(selectedDiets: selectedDiets, onApply: onApply)
        filterVC.modalPresentationStyle = .pageSheet

        if let sheet = filterVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }

        presenter.present(filterVC, animated: true)
    }
}
