//
//  WEDebugger.swift
//  WEServiceExtension
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
        
        guard let userDefaultsData = WEDUtils.getDataFromSharedUserDefaults() else {
            return nil
        }
        
        var event: [String: Any] = [:]
        event["event_name"] = eventName
        event["category"] = "system"
        event["event_time"] = WEDUtils.getCurrentFormattedTime()
        event["event_data"] = eventData
        event["license_code"] = userDefaultsData[WEDConstants.WEX_LICENSE_CODE]
        event["interface_id"] = userDefaultsData[WEDConstants.WEX_INTERFACE_ID]
        
        var systemData: [String: Any] = [:]
        systemData["app_id"] = userDefaultsData[WEDConstants.WEX_APP_ID]
        systemData["sdk_id"] = 3
        if let sdkVersion = userDefaultsData[WEDConstants.WEX_SDK_VERSION] as? String, let intValue = Int(sdkVersion) {
            systemData["sdk_version"] = intValue
        }
        event["system_data"] = systemData
        
        if !debugData.isEmpty {
            event["debug"] = debugData
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
            "log_level": logLevel,
            "log": logMessage,
            "onlydebug": 1,
            "tags": metadata ?? []
        ]
    }
}

@objcMembers
public class WEXLogProcessor: NSObject {
    public static func logReceivedNotification(loglevel: WEGLogLevel, message: Any, notification: UNMutableNotificationContent?){
        if(!WEDUtils.isDebuggerEnabled()){
            return
        }
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaign_id: String = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        let tags = WEGMetadataBuilder.create()
            .addTag(WEDConstants.TAG_PUSH_NOTIFICATION, metadata: [loglevel.description: userInfo])
            .addTag(WEDConstants.TAG_CAMPAIGN_ID, metadata: [loglevel.description : campaign_id])
            .addTag(WEDConstants.WEBENGAGE_BANNER_PUSH, metadata: [loglevel.description :[WEDConstants.KEY_SDK_VERSION: WEDConstants.WEX_SERVICE_EXTENSION_VERSION, WEDConstants.KEY_MESSAGE: message]])
            .build()
        
        let debugData = WEGLogBuilder()
            .level(loglevel.description)
            .message(campaign_id)
            .metadata(tags)
            .buildEventData()
        
        if let event = WEXDebugger.createEvent(eventName: WEDConstants.EVENT_SERVICE_EXTENSION, debugData: debugData){
            WEXDebugger.queueEvent(event) { statusCode, error in
                print(WEDConstants.MSG_DEBUGGER_DATA_SENT)
            }
        }
    }
    
    public static func logtrackEvent(loglevel: WEGLogLevel, event: Any,notification: UNMutableNotificationContent? ){
        if(!WEDUtils.isDebuggerEnabled()){
            return
        }
        
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaign_id: String = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        let tags = WEGMetadataBuilder.create()
            .addTag(WEDConstants.TAG_PUSH_NOTIFICATION, metadata: userInfo)
            .addTag(WEDConstants.TAG_CAMPAIGN_ID, metadata: [loglevel.description : campaign_id])
            .addTag(WEDConstants.WEBENGAGE_BANNER_PUSH, metadata: [loglevel.description :[WEDConstants.KEY_SDK_VERSION: WEDConstants.WEX_SERVICE_EXTENSION_VERSION, WEDConstants.KEY_MESSAGE: event]])
            .build()
        
        let debugData = WEGLogBuilder()
            .level(loglevel.description)
            .message(campaign_id)
            .metadata(tags)
            .buildEventData()
        
        if let event = WEXDebugger.createEvent(eventName: WEDConstants.EVENT_SERVICE_EXTENSION_EVENT, debugData: debugData){
            WEXDebugger.queueEvent(event) { statusCode, error in
                print(WEDConstants.MSG_DEBUGGER_DATA_SENT)
            }
        }
    }
    
    public static func logImageDownloading(loglevel: WEGLogLevel, message: Any, notification: UNMutableNotificationContent?){
        if(!WEDUtils.isDebuggerEnabled()){
            return
        }
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)

        let campaign_id: String = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        let tags = WEGMetadataBuilder.create()
            .addTag(WEDConstants.TAG_PUSH_NOTIFICATION, metadata: [loglevel.description: userInfo])
            .addTag(WEDConstants.TAG_CAMPAIGN_ID, metadata: [loglevel.description : campaign_id])
            .addTag("Resource Downloading", metadata: [loglevel.description :[WEDConstants.KEY_SDK_VERSION: WEDConstants.WEX_SERVICE_EXTENSION_VERSION, WEDConstants.KEY_MESSAGE: message]])
            .addTag(WEDConstants.WEBENGAGE_BANNER_PUSH, metadata: [:])
            .build()
        
        let debugData = WEGLogBuilder()
            .level(loglevel.description)
            .message(campaign_id)
            .metadata(tags)
            .buildEventData()
        
        if let event = WEXDebugger.createEvent(eventName: WEDConstants.EVENT_SERVICE_EXTENSION, debugData: debugData){
            WEXDebugger.queueEvent(event) { statusCode, error in
                print(WEDConstants.MSG_DEBUGGER_DATA_SENT)
            }
        }
    }
    
    public static func logImageDownloadingFailed(loglevel: WEGLogLevel, message: Any, notification: UNMutableNotificationContent? ){
        if(!WEDUtils.isDebuggerEnabled()){
            return
        }
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaign_id: String = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEGMetadataBuilder.create()
            .addTag(WEDConstants.TAG_PUSH_NOTIFICATION, metadata: [loglevel.description:""])
            .addTag(WEDConstants.WEBENGAGE_BANNER_PUSH, metadata: [loglevel.description :[WEDConstants.KEY_SDK_VERSION: WEDConstants.WEX_SERVICE_EXTENSION_VERSION, WEDConstants.KEY_MESSAGE: message]])
            .build()
        
        let debugData = WEGLogBuilder()
            .level(loglevel.description)
            .message("Image Download Failed \(campaign_id)")
            .metadata(tags)
            .buildEventData()
        
        if let event = WEXDebugger.createEvent(eventName: "ServiceExtension", debugData: debugData){
            WEXDebugger.queueEvent(event) { statusCode, error in
                print(WEDConstants.MSG_DEBUGGER_DATA_SENT)
            }
        }
    }
}


