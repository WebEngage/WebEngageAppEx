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
    
    
    // MARK: - Content Extension Delegates
    
    func didReceive(_ notification: UNNotification) {
        
        isRendering = true
        self.notification = notification
        
        if let appGroup = getAppGroup() {
            userDefaults = UserDefaults(suiteName: appGroup)
        }
    }
    
    
    // MARK: -
    
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
}
