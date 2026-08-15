//
//  ViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 08/07/26.
//

import UIKit

class OnBoardingViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var backgroundImageView: UIImageView!
    // MARK: - UI Properties
    private let gradientLayer = CAGradientLayer()
    // MARK: - Properties
    weak var coordinatorDelegate: OnBoardingViewDelegates?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The frame size of the gredient is given after image view bounds are calculated
        gradientLayer.frame = backgroundImageView.bounds
    }
}
// MARK: - UI Configuration
extension OnBoardingViewController {
    private func configureUI() {
        setupGredient()
    }
    private func setupGredient() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        backgroundImageView.layer.addSublayer(gradientLayer)
    }
}
// MARK: - Actions
extension OnBoardingViewController {
    @IBAction private func startButtonTapped(_ sender:UIButton) {
        coordinatorDelegate?.onBoardingDidTapStartCook()
    }
}
