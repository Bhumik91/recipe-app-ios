//
//  ShareAlertPresentationController.swift
//  RecipeApp
//

import UIKit

/// Dims the background behind the presented share alert and sizes/centers the card. Tapping
/// the dimmed area dismisses it, matching the Android dialog's outside-tap-to-close behavior.
final class ShareAlertPresentationController: UIPresentationController {
    private let dimmingView = UIView()
    private enum Metric {
        static let horizontalInset: CGFloat = 24
    }

    override func presentationTransitionWillBegin() {
        guard let containerView else { return }

        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0
        dimmingView.frame = containerView.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped)))
        containerView.insertSubview(dimmingView, at: 0)

        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            dimmingView.alpha = 1
            return
        }
        transitionCoordinator.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            dimmingView.alpha = 0
            return
        }
        transitionCoordinator.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 0
        })
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }

        let width = containerView.bounds.width - Metric.horizontalInset * 2
        let presentedView = presentedViewController.view!
        presentedView.frame.size.width = width
        let height = presentedView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        let originY = (containerView.bounds.height - height) / 2
        return CGRect(x: Metric.horizontalInset, y: originY, width: width, height: height)
    }

    @objc private func dimmingViewTapped() {
        presentingViewController.dismiss(animated: true)
    }
}

/// Fade + scale-in/out transition for the share alert, matching the Android dialog's animation.
final class ShareAlertTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    private let duration: TimeInterval = 0.25

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentation(using: transitionContext)
        } else {
            animateDismissal(using: transitionContext)
        }
    }

    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        toView.frame = transitionContext.finalFrame(for: toViewController)
        toView.alpha = 0
        toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            toView.alpha = 1
            toView.transform = .identity
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }

    private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else {
            transitionContext.completeTransition(false)
            return
        }

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            fromView.alpha = 0
            fromView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
