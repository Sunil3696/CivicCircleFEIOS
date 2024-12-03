//
//  CivicCircleAppApp.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-01.
//

import SwiftUI
import UserNotifications

@main
struct CivicCircleApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SplashView()
            }
        }
    }
}
// MARK: AppDelegate for Notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        // Request notification permissions
        NotificationGenerator.requestAuthorization()

        return true
    }

    // Handle foreground notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📥 Notification received in foreground: \(notification.request.content.title)")
        completionHandler([.alert, .sound, .badge])
    }
}

