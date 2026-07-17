//
//  OnBoardingCoordinator.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 10/07/26.
//
import UIKit

final class OnBoardingCoordinator: ChildCoordinator {
    // MARK: - ChildCoordinator
    typealias ParentDelegate = OnBoardingCoordinatorDelegate
    // MARK: - Properties
    var navigationController: UINavigationController
    weak var parentDelegate: OnBoardingCoordinatorDelegate?
    var container: DependencyContainer? { nil }
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    // MARK: - Coordinator
    func start() {
        showOnBoardingViewController()
    }
}
// MARK: - Navigation
extension OnBoardingCoordinator {
    private func showOnBoardingViewController() {
        guard let onBoardingVC = storyboard.instantiateViewController(
            withIdentifier: "OnBoardingViewController"
        ) as? OnBoardingViewController else {
            fatalError("OnBoardingViewController not found in Main.storyboard")
        }
        
        onBoardingVC.coordinatorDelegate = self
        navigationController.setViewControllers([onBoardingVC], animated: false)
    }
}
// MARK: - OnBoardingViewDelegates
extension OnBoardingCoordinator: OnBoardingViewDelegates {
    func onBoardingDidTapStartCook() {
        self.parentDelegate?.onBoardingFlowDidFinish(self)
    }
}
