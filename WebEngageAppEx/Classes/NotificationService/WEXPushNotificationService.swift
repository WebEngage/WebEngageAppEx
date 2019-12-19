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
        trackEvent {
            self.handler(self.bestAttemptContent)
        }
    }
    
    
    // MARK: - Tracker Event Helpers
    
    func trackEvent(completion: @escaping () -> Void) {
        
        if let request = getTrackerRequest() {
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
        
                if let error = error {
                    NSLog("Error - Could not log push_notification_view event: \(error)")
                } else {
                    NSLog("Successfully fired push_notification_view event")
                }
                
                completion()
            }
        } else {
            completion()
        }
    }
    
    func getTrackerRequest() -> URLRequest? {
        
        if let trackerURL = URL(string: "https://c.webengage.com/tracker") {
            
            var request = URLRequest(url: trackerURL)
            
            request.httpMethod = "POST"
            request.setValue("application/transit+json", forHTTPHeaderField: "Content-type")
            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
            request.httpBody = getTrackerBody()
            
            return request
        }
        
        return nil
    }
    
    func getTrackerBody() -> Data? {
        
        if let userDefaultsData = getUserDefaultsData() {
            
            var body = [String: Any]()
            body["event_name"] = "push_notification_view"
            body["category"] = "system"
            body["suid"] = "null"
            body["luid"] = "null"
            body["cuid"] = "null"
            body["event_data"] = []
            body["event_time"] = sanitizeForTransit(for: getFormattedTime())
            
            if let licenseCode = userDefaultsData["license_code"] as? String {
                body["license_code"] = sanitizeForTransit(for: licenseCode)
            }
            
            if let interfaceID = userDefaultsData["interface_id"] as? String {
                body["interface_id"] = sanitizeForTransit(for: interfaceID)
            }
            
            var systemData = [String: Any]()
            systemData["sdk_id"] = 3
            systemData["sdk_version"] = userDefaultsData["sdk_version"]
            systemData["app_id"] = userDefaultsData["app_id"]
            systemData["experiment_id"] = bestAttemptContent.userInfo["experiment_id"]
            systemData["id"] = bestAttemptContent.userInfo["notification_id"]
            
            body["system_data"] = systemData
            
            do {
                let data = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                
                return data
                
            } catch let error {
                NSLog("Error: \(error)")
            }
        }
        
        return nil
    }
    
    func sanitizeForTransit(for string: String) -> String? {
        
        var sanitizedString: String? = string
        
        if string.hasPrefix("~") && !string.hasPrefix("~t") {
            sanitizedString = "~" + string
        } else if string.hasPrefix("^") {
            sanitizedString = "^" + string
        } else if string.hasPrefix("`") {
            sanitizedString = "`" + string
        } else if string == "null" {
            sanitizedString = nil
        }
        
        return sanitizedString
    }
    
    
    func getUserDefaultsData() -> [String: Any]? {
        
        if let appGroup = getAppGroup() {
            
            if let userDefaults = UserDefaults(suiteName: appGroup) {
                
                NSLog("User Defaults Data: \(userDefaults.dictionaryRepresentation())")
                
                return userDefaults.dictionaryRepresentation()
            }
        }
        
        return nil
    }
    
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
    
    func getFormattedTime() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "'~t'yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "gb")

        return formatter.string(from: Date())
    }
}
