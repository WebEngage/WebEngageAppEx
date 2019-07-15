//
//  WEXRichPushNotificationViewController.swift
//  WEGExtensionApp
//
//  Created by Yogesh Singh on 12/07/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

@available(iOS 10.0, *)
class WEXRichPushNotificationViewController: UIViewController, UNNotificationContentExtension {
    
    var notification: UNNotification?
    var userDefaults: UserDefaults?
//    var currentLayout:
    
    func didReceive(_ notification: UNNotification) {
        
        self.notification = notification
        
        initUserDefaults()
        
        updateActivity(with: false, for: "collapsed")
        updateActivity(with: true, for: "expanded")
        
        if let expandableDetails = notification.request.content.userInfo["expandableDetails"] {
            
        }
    }
    
    func didReceive(_ response: UNNotificationResponse,
                    completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
    }
}



@available(iOS 10.0, *)
extension WEXRichPushNotificationViewController {
    
    func initUserDefaults() {
        
        guard
            Bundle.main.bundleURL.pathExtension == "appex",
            let bundle = Bundle(url: Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()),
            let bundleIdentifier = bundle.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
        else {
            return
        }
        
        let appGroup = "group.\(bundleIdentifier).WEGNotificationGroup"
        userDefaults = UserDefaults.init(suiteName: appGroup)
    }
    
    @discardableResult
    func saveToDefaults(current activity:[String : Any]) -> Bool {
        
        guard
            let expID = notification?.request.content.userInfo["experiment_id"] as? String,
            let notifID = notification?.request.content.userInfo["notification_id"] as? String
        else {
            return false
        }
        
        let finalNotifID = expID + "|" + notifID
        
        userDefaults?.set(activity, forKey: finalNotifID)
        
        return true
    }
    
    func getCurrentNotificationActivity() -> [String : Any]? {
        
        guard
            let expID = notification?.request.content.userInfo["experiment_id"] as? String,
            let notifID = notification?.request.content.userInfo["notification_id"] as? String,
            let expandableDetails = notification?.request.content.userInfo["expandableDetails"]
        else {
            return nil
        }
        
        let finalNotifID = expID + "|" + notifID
        
        guard let activity = userDefaults?.dictionary(forKey: finalNotifID) else {
            
            var createdActivity = [String: Any]()
            
            createdActivity["experiment_id"] = expID
            createdActivity["notification_id"] = notifID
            createdActivity["expandableDetails"] = expandableDetails
            
            if let customData = notification?.request.content.userInfo["customData"] {
                createdActivity["customData"] = customData
            }
            
            return createdActivity
        }
        
        return activity
    }
    
    @discardableResult
    func updateActivity(with object: Any, for key: String) -> Bool {
        
        if var activity = getCurrentNotificationActivity() {
            
            activity[key] = object
            
            return saveToDefaults(current: activity)
        }
        
        return false
    }
}
