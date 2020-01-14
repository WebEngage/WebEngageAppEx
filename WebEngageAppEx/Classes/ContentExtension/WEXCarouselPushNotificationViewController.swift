//
//  WEXCarouselPushNotificationViewController.swift
//  ContentExtension
//
//  Created by Yogesh Singh on 20/12/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit

class WEXCarouselPushNotificationViewController: WEXRichPushLayout {
    
    var current = 0
    var isRendering = false
    var carouselItems: [Any]?
    var images: [String]?
    var wasLoaded: [String]?
    
    var notification: UNNotification?
//    var userDefaults: UserDefaults?
//    var currentLayout: WEXRichPushLayout?
    
    // MARK: - Content Extension Delegates
    
    override func didReceive(_ notification: UNNotification) {
        
        current = 0
        isRendering = true
        self.notification = notification
        
        if setupCarouselItems(from: notification) {
        
            let downloadedCount = notification.request.content.attachments.count
            
        }
    }
    
    
    // MARK: - View Helpers
    
    func setupCarouselItems(from notification: UNNotification) -> Bool {
     
        if let expandableDetails = notification.request.content.userInfo["expandableDetails"] as? [AnyHashable: Any] {
            
            if let items = expandableDetails["items"] as? [Any] {
                
                if items.count > 0 {
                    carouselItems = items
                    return true
                }
            }
        }
        
        return false
    }
}
