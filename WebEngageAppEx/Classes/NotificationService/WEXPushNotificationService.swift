//
//  WEXPushNotificationService.swift
//  ServiceExtension
//
//  Created by Yogesh Singh on 16/12/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit

class WEXPushNotificationService: UNNotificationServiceExtension {

    var bestAttemptContent = UNMutableNotificationContent()
    var handler: (UNNotificationContent) -> Void = { _ in }
    
    
    // MARK: - Service Extension Delegates

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        NSLog("Push Notification content: \(request.content.userInfo)")

        if let content = request.content.mutableCopy() as? UNMutableNotificationContent {
            bestAttemptContent = content
            handler = contentHandler
        }
        
        guard
            let expandableDetails = request.content.userInfo["expandableDetails"] as? [AnyHashable: Any],
            let style = expandableDetails["style"] as? String
        else {
            self.handler(self.bestAttemptContent)
            return
        }
        
        
        switch style {
        case "BIG_PICTURE", "RATING_V1":
        
            if let imageURL = expandableDetails["image"] as? String {
                drawBannerView(with: imageURL)
            } else {
                fireTracker()
            }
            
        case "CAROUSEL_V1":
            
            if let items = expandableDetails["items"] as? [[AnyHashable: Any]] {
                drawCarouselView(with: items)
            } else {
                fireTracker()
            }
            
        default:
            fireTracker()
        }
    }
    
    
    override func serviceExtensionTimeWillExpire() {
        self.handler(self.bestAttemptContent)
    }
    
    
    // MARK: - Rich View Helpers
    
    func drawBannerView(with imageURL: String) {
        
        fetchAttachment(for: imageURL, index: "0") { (attachment, index) in
            
            NSLog("WebEngage Banner View Rich Push Image downloaded")
            
            if let attachment = attachment {
                self.bestAttemptContent.attachments = [attachment]
            }
            
            self.fireTracker()
        }
    }
    
    
    func drawCarouselView(with items:[[AnyHashable: Any]]) {

        if items.count > 2 {

            var itemCounter = 0
            var imageCounter = 0
            var attachments: [UNNotificationAttachment] = []
            
            for carouselItem in items {

                if let imageURL = carouselItem["image"] as? String {
                 
                    fetchAttachment(for: imageURL, index: "\(itemCounter)") { (attachment, index) in
                        
                        imageCounter += 1
                        
                        if let attachment = attachment {
                            attachments.append(attachment)
                        }
                        
                        if imageCounter == items.count {
                            
                            self.bestAttemptContent.attachments = attachments
                            
                            self.fireTracker()
                        }
                    }
                }
                
                itemCounter += 1
            }
        }
    }
    
    
    func fetchAttachment(for urlString: String, index: String,
                         completion: @escaping (UNNotificationAttachment?, String) -> Void) {
        
        guard let fetchURL = URL(string: urlString) else {
            completion(nil, index)
            return
        }
        
        let fileExtension = "." + (urlString as NSString).pathExtension
        
        URLSession.shared.downloadTask(with: fetchURL) { (url, response, error) in
            
            if let error = error {
                NSLog("Error downloading content: \(error)")
            }
            
            if let temporaryFileLocation = url {
                
                if let fileURL = URL(string: (temporaryFileLocation.path + fileExtension)) {
                    
                    do {
                        
                        try FileManager.default.moveItem(at: temporaryFileLocation, to: fileURL)
                        let attachment = try UNNotificationAttachment(identifier: index, url: fileURL, options: nil)

                        completion(attachment, index)
                        
                        return
                        
                    } catch let error {
                        NSLog("Error: \(error)")
                    }
                }
            }
            
            completion(nil, index)
            
        }.resume()
    }
    
    
    func fireTracker() {
        self.trackEvent {
            self.handler(self.bestAttemptContent)
        }
    }
    
    
    // MARK: - Tracker Event Helpers
    
    func trackEvent(completion: @escaping () -> Void) {
        
        completion()
    }
}
