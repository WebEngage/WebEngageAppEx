//
//  WEXRichPushNotificationViewController.swift
//  ContentExtension
//
//  Created by Yogesh Singh on 19/12/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit

class WEXRichPushNotificationViewController: UIViewController, UNNotificationContentExtension {
    
    var isRendering = false
    var notification: UNNotification?
    var userDefaults: UserDefaults?
    var currentLayout: WEXRichPushLayout?
    
    
    // MARK: - Content Extension Delegates
    
    func didReceive(_ notification: UNNotification) {
        
        isRendering = true
        self.notification = notification
        
        if let appGroup = getAppGroup() {
            userDefaults = UserDefaults(suiteName: appGroup)
        }
        
        updateActivity(object: false, key: "collapsed")
        updateActivity(object: true, key: "expanded")
        
        if let expandableDetails = notification.request.content.userInfo["expandableDetails"] as? [AnyHashable: Any] {
            
            if let style = expandableDetails["style"] as? String {
                
                if let currentLayout = getLayout(for: style) {
                    
                    self.currentLayout = currentLayout
                    currentLayout.didReceive(notification)
                }
            }
        }
    }
    
    func didReceive(_ response: UNNotificationResponse,
                    completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        currentLayout?.didReceive(response, completionHandler: completion)
    }
    
    
    // MARK: - View Helpers
    
    func getAppGroup() -> String? {
        
        if let appGroup = Bundle.main.object(forInfoDictionaryKey: "WEX_APP_GROUP") as? String {
            
            return appGroup
        }
            
        if Bundle.main.bundleURL.pathExtension == "appex" {
            
            if let bundle = Bundle(url: Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()) {
                if let identifier = bundle.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String {
                    
                    return "group.\(identifier).WEGNotificationGroup"
                }
            }
        }
        
        return nil
    }
    
    
    func getLayout(for style: String) -> WEXRichPushLayout? {
        
        switch style {
        case "CAROUSEL_V1":
            return WEXCarouselPushNotificationViewController(with: self)
        case "RATING_V1":
            return WEXRatingPushNotificationViewController(with: self)
        default:
            return nil
        }
    }
    
    
    // MARK: - Notification Activity Data
    
    func getActivity() -> [AnyHashable: Any]? {
        
        guard
            let notification = notification,
            let expID = notification.request.content.userInfo["experiment_id"] as? String,
            let notifID = notification.request.content.userInfo["notification_id"] as? String,
            let expandableDetails = notification.request.content.userInfo["expandableDetails"],
            let userDefaults = userDefaults
        else {
            return nil
        }
        
        let finalNotifID = expID + "|" + notifID

        if let dictionary = userDefaults.dictionary(forKey: finalNotifID) {
            return dictionary
        } else {
           
            var dictionary = [AnyHashable: Any]()
            dictionary["experiment_id"] = expID
            dictionary["notification_id"] = notifID
            dictionary["expandableDetails"] = expandableDetails
            
            if let customData = notification.request.content.userInfo["customData"] {
                dictionary["customData"] = customData
            }
            
            return dictionary
        }
    }
    
    func setActivity(for activity: [AnyHashable: Any]) {
        
        guard
            let notification = notification,
            let expID = notification.request.content.userInfo["experiment_id"] as? String,
            let notifID = notification.request.content.userInfo["notification_id"] as? String,
            let userDefaults = userDefaults
        else {
            return
        }
        
        let finalNotifID = expID + "|" + notifID
        
        userDefaults.set(activity, forKey: finalNotifID)
    }
    
    func updateActivity(object: Any, key: String) {
        
        if var activity = getActivity() {
            
            activity[key] = object
            
            setActivity(for: activity)
        }
    }
}
