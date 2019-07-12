//
//  WEXPushNotificationService.swift
//  WEGExtensionApp
//
//  Created by Yogesh Singh on 08/07/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UserNotifications

@available(iOS 10.0, *)
class WEXPushNotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        self.bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent
        
        print("Push Notification Content: \(request.content.userInfo)")
        
        guard
            let details = request.content.userInfo["expandableDetails"] as? [AnyHashable: Any],
            let style = details["style"] as? String
            else { return deliverContent() }
        
        switch style {
        case "CAROUSEL_V1":
            loadCarouselView(with: details)
        case "RATING_V1":
            loadRatingView(with: details)
        case "BIG_PICTURE":
            loadRatingView(with: details)
        default:
            deliverContent()
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        deliverContent()
    }
}

@available(iOS 10.0, *)
extension WEXPushNotificationService {
    
    /// Delivers the currently available modified notification content on contentHandler
    func deliverContent() {
        if let handler = contentHandler, let content = bestAttemptContent {
            handler(content)
        }
    }
    
    func loadCarouselView(with details: [AnyHashable: Any]) {
        
        guard let items = details["items"] as? [[AnyHashable: Any]], items.count >= 3 else {
            return deliverContent()
        }
        
        var itemsCounter = 0
        var imageCounter = 0
        var attachmentsArray = [UNNotificationAttachment]()
        
        for item in items {
            if let imageStr = item["image"] as? String {
                if let imageURL = URL(string: imageStr) {
                    
                    fetchAttachment(for: imageURL, at: itemsCounter) { (attachment) in
                        
                        imageCounter += 1
                        
                        if let mediaAttachment = attachment {
                            attachmentsArray.append(mediaAttachment)
                            self.bestAttemptContent?.attachments = attachmentsArray
                        }
                        
                        if imageCounter == items.count {
                            self.deliverContent()
                        }
                    }
                    
                    itemsCounter += 1
                }
            }
        }
    }
    
    func loadRatingView(with details: [AnyHashable: Any]) {
        
        if let imageStr = details["image"] as? String {
            if let imageURL = URL(string: imageStr) {
                fetchAttachment(for: imageURL, at: 0) { (attachment) in
                    if let mediaAttachment = attachment {
                        self.bestAttemptContent?.attachments = [mediaAttachment]
                    }
                    
                    self.deliverContent()
                }
            }
        }
    }
    
    func fetchAttachment(for imageURL: URL,
                         at index: Int,
                         completion handler: @escaping (UNNotificationAttachment?) -> Void) {
        
        let pathExtension = "." + imageURL.pathExtension
        
        URLSession.shared.downloadTask(with: imageURL) { (fileLocationURL, response, error) in
            
            var attachment: UNNotificationAttachment?
            
            if let error = error {
                print("error: \(error)")
            } else {
                if let fileLocationURL = fileLocationURL {
                    let localURL = URL(fileURLWithPath: fileLocationURL.path.appending(pathExtension))
                    
                    do {
                        
                        try FileManager.default.moveItem(at: fileLocationURL, to: localURL)
                        
                        attachment = try UNNotificationAttachment(identifier: "\(index)", url: localURL, options: nil)
                        
                    } catch let error {
                        print("error: \(error)")
                    }
                }
            }
            
            handler(attachment)
            
            }.resume()
    }
}
