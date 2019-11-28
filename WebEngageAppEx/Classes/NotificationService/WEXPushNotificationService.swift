//
//  WEXPushNotificationService.swift
//  ServiceExtension
//
//  Created by Yogesh Singh on 27/11/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit
import os.log

class WEXPushNotificationService: UNNotificationServiceExtension {


    // MARK:- Service Extension Delegates

//    var contentHandler: (UNNotificationContent) -> Void
//    var bestAttemptContent: UNNotificationContent
    
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        os_log("Push Notification content: ", request.content.userInfo)
        
//        self.contentHandler = contentHandler
//        self.bestAttemptContent = request.content.mutableCopy() as! UNNotificationContent
        
        if let expandableDetails = request.content.userInfo["expandableDetails"] as? [AnyHashable: Any] {
        
            if let style = expandableDetails["style"] as? String {
             
                switch style {
                case "CAROUSEL_V1":
                    drawCarouselView()
                    
                case "RATING_V1":
                    drawBannerView()
                    
                case "BIG_PICTURE":
                    drawBannerView()
                    
                default:
                    trackEventWith {
                        contentHandler(request.content.mutableCopy() as! UNNotificationContent)
                    }
                }
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        
    }

    
    // MARK:- Rich Push View Helpers
    
    func drawCarouselView() {
        
    }
    
    func drawBannerView() {
        
    }

    
    // MARK:- Tracker Event Helpers
    
    func trackEventWith(completion: @escaping () -> Void) {
        
    }
}
