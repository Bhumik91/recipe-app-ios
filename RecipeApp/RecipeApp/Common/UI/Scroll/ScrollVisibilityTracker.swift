//
//  ScrollVisibilityTracker.swift
//  RecipeApp
//

import UIKit

/// Pure scroll-direction detector shared by every "hide on scroll down, show the
/// instant the user scrolls back up" surface (bottom nav, Home header, nav bars).
/// Knows nothing about what it's hiding — callers feed it a scroll view and act on
/// the result, which keeps the visual effect fully decoupled from this decision logic.
@MainActor
final class ScrollVisibilityTracker {
    struct Configuration {
        /// How close to the top still counts as "at the top" — where the tracked
        /// surface is always forced visible regardless of the last drag direction.
        var topTolerance: CGFloat
        /// Drags slower than this are ignored so momentum settling and small
        /// jitters don't flip the state.
        var minVelocity: CGFloat

        init(topTolerance: CGFloat = 8, minVelocity: CGFloat = 50) {
            self.topTolerance = topTolerance
            self.minVelocity = minVelocity
        }
    }

    private let configuration: Configuration
    private(set) var isHidden = false

    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    /// Feed every scroll update. Returns the new hidden state only on the tick it
    /// actually changes, so callers can apply the effect without deduping themselves.
    @discardableResult
    func handle(scrollView: UIScrollView) -> Bool? {
        // Always visible near the top, whichever way the last drag went.
        let topOffset = -scrollView.contentInset.top
        guard scrollView.contentOffset.y > topOffset + configuration.topTolerance else {
            return setHidden(false)
        }

        // Velocity is 0 once the finger lifts, so momentum scrolling holds the
        // current state instead of flickering.
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView.superview ?? scrollView).y
        if velocity < -configuration.minVelocity {
            return setHidden(true)   // dragging up = reading further down
        } else if velocity > configuration.minVelocity {
            return setHidden(false)  // dragging back down = scrolling up
        }
        return nil
    }

    /// Resets to visible without animation bookkeeping — for tab switches, view
    /// re-appearances, and other moments the surface should just be there again.
    func forceShow() {
        isHidden = false
    }

    private func setHidden(_ hidden: Bool) -> Bool? {
        guard hidden != isHidden else { return nil }
        isHidden = hidden
        return hidden
    }
}
