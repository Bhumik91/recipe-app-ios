//
//  ViewController.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 08/07/26.
//

import UIKit

class OnBoardingViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    // MARK: UI related Properties
    private let gradientLayer = CAGradientLayer()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    override func viewDidLayoutSubviews() {
        // The frame size of the gredient is given after image view bounds are calculated
        gradientLayer.frame = backgroundImageView.bounds
    }
}
//MARK: Extension for implementing of UI related things
extension OnBoardingViewController {
    private func setupUi() {
        setupGredient()
        
    }
    //MARK: Setup gredient on back ground image
    private func setupGredient() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        backgroundImageView.layer.addSublayer(gradientLayer)
    }
}
//MARK: Extensions for handling IBActions taps
extension OnBoardingViewController {
    @IBAction private func startButtonTapped(_ sender:UIButton) {
        //TODO: Navigate towards Authentication flow
    }
}
