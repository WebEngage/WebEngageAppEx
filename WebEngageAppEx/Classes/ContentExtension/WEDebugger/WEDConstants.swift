//
//  WEDUtils.swift
//  WEContentExtension
//
//  Created by Shubham Naidu on 07/12/25.
//

import Foundation

struct WEDConstants{
    static let KEY_DEBUGGER_EVENT_SYNC_URL = "debugger_event_sync_url"
    static let WEX_LICENSE_CODE = "license_code"
    static let WEX_INTERFACE_ID = "interface_id"
    static let WEX_SDK_VERSION = "sdk_version"
    static let WEX_APP_ID = "app_id"
    static let WE_CONTENT_EXTENSION = "WEContentExtension"
    static let WEX_CONTENT_EXTENSION_VERSION = "1.3.2"
    static let WEX_APP_GROUP = "WEX_APP_GROUP"
    static let KEY_NOTIFICATION_ID = "notification_id"
    static let KEY_SDK_VERSION = "sdk_version"
    static let KEY_MESSAGE = "message"
    static let KEY_TAG = "tag"
    static let KEY_METADATA = "metadata"
    static let KEY_SYSTEM_DATA_OVERRIDES = "system_data_overrides"
    static let KEY_ID = "id"
    static let KEY_LOG_LEVEL = "log_level"
    static let KEY_LOG = "log"
    static let KEY_ONLYDEBUG = "onlydebug"
    static let KEY_TAGS = "tags"
    static let KEY_EVENT_NAME = "event_name"
    static let KEY_CATEGORY = "category"
    static let KEY_EVENT_TIME = "event_time"
    static let KEY_EVENT_DATA = "event_data"
    static let KEY_SYSTEM_DATA = "system_data"
    static let KEY_DEBUG = "debug"
    static let APPEX = "appex"
    static let WENOTIFICATIONGROUP = "WEGNotificationGroup"
    static let CFBUNDLEIDENTIFIER = "CFBundleIdentifier"
    static let GROUP = "group"
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

@objcMembers
public class WEGDebugTags: NSObject {
    public static let pushNotification = "Push Notification"
    public static let campaign_Id = "Campaign_id"
}
