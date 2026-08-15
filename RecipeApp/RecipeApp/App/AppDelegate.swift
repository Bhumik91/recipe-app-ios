//
//  AppDelegate.swift
//  RecipeApp
//
//  Created by Bhumik Poshiya on 08/07/26.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Both must be set before this returns, or a launch tap is dropped and the first
        // notification posts without its category.
        UNUserNotificationCenter.current().delegate = self
        NotificationCategories.register()
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // Use this method to release any resources that were specific to the discarded scenes.
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    /// Without this, iOS suppresses the banner while the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    /// Fired when the user taps a delivered notification, including a cold-launch tap.
    /// `NotificationDeepLinkRouter` buffers the link if the coordinator tree isn't up yet.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Decode before hopping to the main actor: `response` is a reference type owned by the
        // notification centre, while the decoded deep link is a value we can safely hand over.
        let deepLink = NotificationDeepLink(userInfo: response.notification.request.content.userInfo)
        completionHandler()

        guard let deepLink else { return }
        Task { @MainActor in
            NotificationDeepLinkRouter.shared.route(deepLink)
        }
    }
}
