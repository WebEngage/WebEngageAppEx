//
//  WEDUtils.swift
//  WEContentExtension
//
//  Created by Shubham Naidu on 07/12/25.
//

import Foundation

struct WEDUtils{
    
    static func isDebuggerEnabled() -> Bool {
        return  self.getSharedUserDefaults()?
            .string(forKey: WEDConstants.KEY_DEBUGGER_EVENT_SYNC_URL) != nil
    }
    
    /// Converts notification userInfo to [String: Any] dictionary
    /// - Parameter notification: UNMutableNotificationContent or similar with userInfo property
    /// - Returns: Dictionary with string keys and any values
    static func convertUserInfoToDictionary(_ notification: Any?) -> [String: Any] {
        guard let userInfo = (notification as? UNNotificationContent)?.userInfo else {
            return [:]
        }
        return userInfo.reduce(into: [String: Any]()) { result, element in
            if let key = element.key as? String {
                result[key] = element.value
            }
        }
    }
    
    static func getSharedUserDefaults() -> UserDefaults? {
        var appGroup = Bundle.main.object(forInfoDictionaryKey: WEDConstants.WEX_APP_GROUP) as? String

        if appGroup == nil {
            var bundle = Bundle.main
            if bundle.bundleURL.pathExtension == WEDConstants.APPEX {
                bundle = Bundle(url: bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent())!
            }
            let bundleIdentifier = bundle.object(forInfoDictionaryKey: WEDConstants.CFBUNDLEIDENTIFIER) as? String
            appGroup = "\(WEDConstants.GROUP).\(bundleIdentifier ?? "").\(WEDConstants.WENOTIFICATIONGROUP)"
        }

        if let defaults = UserDefaults(suiteName: appGroup) {
            return defaults
        }
        return nil
    }
    
    static func getCurrentFormattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "'~t'yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_GB")
        return formatter.string(from: Date())
    }
    
    
}
