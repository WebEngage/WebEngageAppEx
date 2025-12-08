//
//  WEDebugger.swift
//  WEContentExtension
//
//  Created by Shubham Naidu on 25/03/25.
//

import Foundation

/// A debugger utility for making network calls.
struct WEXDebugger {
    
    private static var eventQueue: [[String: Any]] = []
    private static let maxEvents = 5
    private static let queueLock = NSLock()
    
    /// Creates an event dictionary
    static func createEvent(eventName: String,
                            eventData: [String: Any] = [:],
                            debugData: [String: Any] = [:]) -> [String: Any]? {
        
        guard let userDefaultsData = WEDUtils.getSharedUserDefaults() else {
            return nil
        }
        
        var event: [String: Any] = [:]
        event[WEDConstants.KEY_EVENT_NAME] = eventName
        event[WEDConstants.KEY_CATEGORY] = "system"
        event[WEDConstants.KEY_EVENT_TIME] = WEDUtils.getCurrentFormattedTime()
        event[WEDConstants.KEY_EVENT_DATA] = eventData
        event[WEDConstants.WEX_LICENSE_CODE] = userDefaultsData.string(forKey: WEDConstants.WEX_LICENSE_CODE)
        event[WEDConstants.WEX_INTERFACE_ID] = userDefaultsData.string(forKey: WEDConstants.WEX_INTERFACE_ID)
        
        var systemData: [String: Any] = [:]
        systemData[WEDConstants.WEX_APP_ID] = userDefaultsData.string(forKey: WEDConstants.WEX_APP_ID)
        systemData["sdk_id"] = 3
        if let sdkVersion = userDefaultsData.string(forKey: WEDConstants.WEX_SDK_VERSION), let intValue = Int(sdkVersion) {
            systemData[WEDConstants.KEY_SDK_VERSION] = intValue
        }
        event[WEDConstants.KEY_SYSTEM_DATA] = systemData
        
        if !debugData.isEmpty {
            event[WEDConstants.KEY_DEBUG] = debugData
        }
        
        return event
    }
    
    /// Queues an event and sends batch when limit is reached
    /// - Parameters:
    ///   - event: Event dictionary to queue
    ///   - completion: Completion handler called when batch is sent
    static func queueEvent(_ event: [String: Any], completion: @escaping (Int, Error?) -> Void = { _, _ in }) {
        queueLock.lock()
        defer { queueLock.unlock() }
        
        eventQueue.append(event)
        
        if eventQueue.count >= maxEvents {
            let eventsToSend = eventQueue
            eventQueue.removeAll()
            sendEvents(eventsToSend, completion: completion)
        }
    }
    
    /// Sends all queued events immediately
    /// - Parameter completion: Completion handler with status code and optional error
    static func flushEvents(completion: @escaping (Int, Error?) -> Void = { _, _ in }) {
        queueLock.lock()
        defer { queueLock.unlock() }
        
        guard !eventQueue.isEmpty else {
            completion(200, nil)
            return
        }
        
        let eventsToSend = eventQueue
        eventQueue.removeAll()
        sendEvents(eventsToSend, completion: completion)
    }
    
    /// Sends events to the server via POST request
    /// - Parameters:
    ///   - events: Array of event dictionaries to send
    ///   - completion: Completion handler with status code and optional error
    private static func sendEvents(_ events: [[String: Any]],
                           completion: @escaping (Int, Error?) -> Void) {
        
        guard let defaults = WEDUtils.getSharedUserDefaults(), let urlString = defaults.string(forKey: WEDConstants.KEY_DEBUGGER_EVENT_SYNC_URL) else {
            return
        }
                
                
        guard let url = URL(string: urlString) else {
            completion(-1, NSError(domain: "WEDNetwork", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add headers
        let headers = ["Authorization": "Bearer your_token"]
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Convert events array to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: events, options: [])
            request.httpBody = jsonData
        } catch {
            completion(-1, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(-1, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode, nil)
            } else {
                completion(-1, NSError(domain: "WEDNetwork", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Response"]))
            }
        }
        
        task.resume()
    }
    
}


@objcMembers
public class WEGMetadataBuilder: NSObject {
    
    public static func create() -> WEGMetadataBuilder {
        return WEGMetadataBuilder()
    }
    
    private var tags: [[String: Any]] = []
    
    public func addTag(_ tag: String, metadata: [String: Any]) -> WEGMetadataBuilder {
        if let index = tags.firstIndex(where: { $0[WEDConstants.KEY_TAG] as? String == tag }) {
            if var existingMetadata = tags[index][WEDConstants.KEY_METADATA] as? [String: Any] {
                existingMetadata.merge(metadata) { _, new in new }
                tags[index] = [WEDConstants.KEY_TAG: tag, WEDConstants.KEY_METADATA: existingMetadata]
            }
        } else {
            tags.append([WEDConstants.KEY_TAG: tag, WEDConstants.KEY_METADATA: metadata])
        }
        return self
    }
    
    public func build() -> [[String: Any]] {
        return tags
    }
}

@objcMembers
public class WEGLogBuilder: NSObject {
    
    private var logLevel: String = "info"
    private var logMessage: String = ""
    private var eventName: String?
    private var metadata: [[String: Any]]?
    
    public func level(_ level: String) -> WEGLogBuilder {
        logLevel = level
        return self
    }
    
    public func message(_ message: String) -> WEGLogBuilder {
        logMessage = message
        return self
    }
    
    public func eventName(_ name: String) -> WEGLogBuilder {
        eventName = name
        return self
    }
    
    public func metadata(_ meta: [[String: Any]]?) -> WEGLogBuilder {
        metadata = meta
        return self
    }
    
    public func buildEventData() -> [String: Any] {
        return [
            WEDConstants.KEY_LOG_LEVEL: logLevel,
            WEDConstants.KEY_LOG: logMessage,
            WEDConstants.KEY_ONLYDEBUG: 1,
            WEDConstants.KEY_TAGS: metadata ?? []
        ]
    }
}

@objcMembers
public class WEXLogProcessor: NSObject {
    public static func logReceivedNotification(loglevel: WEGLogLevel, message: Any, notification: UNNotificationContent?){
        if(!WEDUtils.isDebuggerEnabled()){
            return
        }
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaign_id: String = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEGMetadataBuilder.create()
            .addTag(WEGDebugTags.pushNotification, metadata: [loglevel.description: userInfo])
            .addTag(WEGDebugTags.campaign_Id, metadata: [loglevel.description : campaign_id])
            .addTag(WEConstants.WEBENGAGE_APPEX, metadata: [loglevel.description :[WEDConstants.KEY_SDK_VERSION: WEConstants.WEX_CONTENT_EXTENSION_VERSION, WEDConstants.KEY_MESSAGE:message]])
            .build()
        
        let debugData = WEGLogBuilder()
            .level(loglevel.description)
            .message(campaign_id)
            .metadata(tags)
            .buildEventData()
        
        if let event = WEXDebugger.createEvent(eventName: "Content Extension (Notification Expanded)", debugData: debugData){
            WEXDebugger.queueEvent(event) { statusCode, error in
                print("Debugger Data sent")
            }
        }
    }
    
    public static func logImageDownloadingFailed(loglevel: WEGLogLevel, message: Any,notification: UNNotificationContent?){
        if(!WEDUtils.isDebuggerEnabled()){
            return
        }
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaign_id: String = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        let tags = WEGMetadataBuilder.create()
            .addTag(WEGDebugTags.pushNotification, metadata: [loglevel.description:""])
            .addTag("Resource Downloading", metadata: [loglevel.description :[WEDConstants.KEY_SDK_VERSION: WEConstants.WEX_CONTENT_EXTENSION_VERSION, WEDConstants.KEY_MESSAGE:message]])
            .addTag(WEConstants.WEBENGAGE_APPEX, metadata: [:])
            .build()
        
        let debugData = WEGLogBuilder()
            .level(loglevel.description)
            .message("Image Download Failed for \(campaign_id)")
            .metadata(tags)
            .buildEventData()
        
        if let event = WEXDebugger.createEvent(eventName: "Content Extension", debugData: debugData){
            WEXDebugger.queueEvent(event) { statusCode, error in
                print("Debugger Data sent")
            }
        }
    }
    
    public static func logtrackEvent(loglevel: WEGLogLevel, event: Any, eventValue: [String: Any]?){
        if(!WEDUtils.isDebuggerEnabled()){
            return
        }
        
        let overrides = eventValue?[WEDConstants.KEY_SYSTEM_DATA_OVERRIDES] as? [String: Any]
        let campaign_id = overrides?[WEDConstants.KEY_ID] as? String ?? ""
        
        let tags = WEGMetadataBuilder.create()
            .addTag(WEGDebugTags.pushNotification, metadata: eventValue ?? [:])
            .addTag(WEGDebugTags.campaign_Id, metadata: [loglevel.description : campaign_id])
            .addTag(WEConstants.WEBENGAGE_APPEX, metadata: [loglevel.description :[WEDConstants.KEY_SDK_VERSION: WEConstants.WEX_CONTENT_EXTENSION_VERSION, WEDConstants.KEY_MESSAGE:event]])
            .build()
        
        let debugData = WEGLogBuilder()
            .level(loglevel.description)
            .message(campaign_id)
            .metadata(tags)
            .buildEventData()
        
        if let event = WEXDebugger.createEvent(eventName: "Content Extension Event", debugData: debugData){
            WEXDebugger.queueEvent(event) { statusCode, error in
                print("Debugger Data sent")
            }
        }
    }
}


