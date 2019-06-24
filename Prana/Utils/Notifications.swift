//
//  Notifications.swift
//  TestTimer
//
//  Created by Luccas on 5/21/19.
//  Copyright © 2019 Guru. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class Notifications: NSObject {
    
    let center = UNUserNotificationCenter.current()
    var options: UNAuthorizationOptions = [.alert, .sound, .badge]
    var appDelegate: AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    func requestAllowNotification() {
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                // Notifications not allowed
                self.center.requestAuthorization(options: self.options) {
                    (didAllow, error) in
                    if !didAllow {
                        print("User has declined notifications")
                    }
                }
            }
        }
    }
    
    func applicationDidBecomeActive() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func removeNotifications(identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func scheduleDailyNotification(title: String, body: String, date: Date, identifier: String) {
        
        let content = UNMutableNotificationContent()
//        let userActions = "User Actions"
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
//        content.categoryIdentifier = userActions
        
        let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
//        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
//        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
//        let category = UNNotificationCategory(identifier: userActions, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
//
//        center.setNotificationCategories([category])
    }
    
    func scheduleIntervalNotification(title: String, body: String, interval: TimeInterval, identifier: String) {
        
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
}

extension Notifications: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
//        if response.notification.request.identifier == "Local Notification" {
//            print("Handling notifications with the Local Notification Identifier")
//        }
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
//        case "Snooze":
//            print("Snooze")
//        case "Delete":
//            print("Delete")
        default:
            print("Unknown action")
        }
        
        completionHandler()
    }
}
