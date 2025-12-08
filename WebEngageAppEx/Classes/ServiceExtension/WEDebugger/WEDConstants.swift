//
//  WEDConstants.swift
//  WEServiceExtension
//
//  Created by Shubham Naidu on 07/12/25.
//

import Foundation

struct WEDConstants {
    
    static let KEY_DEBUGGER_EVENT_SYNC_URL = "debugger_event_sync_url"
    static let WEBENGAGE_BANNER_PUSH = "WebEngageBannerPush"
    static let WEX_SERVICE_EXTENSION_VERSION = "1.3.2"
    
    static let WEX_LICENSE_CODE = "license_code"
    static let WEX_INTERFACE_ID = "interface_id"
    static let WEX_SDK_VERSION = "sdk_version"
    static let WEX_APP_ID = "app_id"
    
    // Event keys
    static let KEY_NOTIFICATION_ID = "notification_id"
    static let KEY_SDK_VERSION = "sdk_version"
    static let KEY_MESSAGE = "message"
    static let KEY_TAG = "tag"
    static let KEY_METADATA = "metadata"
    
    
    // Tag names
    static let TAG_PUSH_NOTIFICATION = "Push Notification"
    static let TAG_CAMPAIGN_ID = "Campaign_id"
    
    // Event names
    static let EVENT_SERVICE_EXTENSION = "Service Extension"
    static let EVENT_SERVICE_EXTENSION_EVENT = "Service Extension Event"
    
    // Messages
    static let MSG_DEBUGGER_DATA_SENT = "Debugger Data sent"
    
    static let APPEX = "appex"
    static let WENOTIFICATIONGROUP = "WEGNotificationGroup"
    static let CFBUNDLEIDENTIFIER = "CFBundleIdentifier"
    static let GROUP = "group"
    static let WEX_APP_GROUP = "WEX_APP_GROUP"
    
}


@objc public enum WEGLogLevel: Int {
    case debug, info, warning, error, critical
    
    var description: String {
        switch self {
        case .debug: return "debug"
        case .info: return "info"
        case .warning: return "warning"
        case .error: return "error"
        case .critical: return "critical"
        }
    }
}
