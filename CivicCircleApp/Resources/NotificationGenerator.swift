//
//  NotificationGenerator.swift
//  CivicCircleApp
//
//  Created by Sunil Balami on 2024-12-03.
//

import Foundation
import UserNotifications

class NotificationGenerator {
    static func generateNotification(title: String, description: String, startDate: Date, endDate: Date) {
        // Request notification authorization
        requestAuthorization()

        // Initial notification: 15 seconds after joining
        let initialTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        scheduleNotification(
            title: title,
            description: "Event starts soon: \(description)",
            trigger: initialTrigger
        )
        
        // Daily notifications
        let calendar = Calendar.current
        var nextDate = startDate
        
        while nextDate <= endDate {
            // Create a trigger for the same time each day
            let components = calendar.dateComponents([.hour, .minute, .second], from: nextDate)
            let dailyTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            scheduleNotification(
                title: title,
                description: "Daily reminder for the event: \(description)",
                trigger: dailyTrigger
            )
            
            // Move to the next day
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
        }
    }

    private static func scheduleNotification(title: String, description: String, trigger: UNNotificationTrigger) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = description
        content.sound = .default
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification scheduled successfully for \(trigger)")
            }
        }
    }

    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Error requesting authorization: \(error.localizedDescription)")
            } else if granted {
                print("✅ Notification authorization granted")
            } else {
                print("❌ Notification authorization denied")
            }
        }
    }
}
