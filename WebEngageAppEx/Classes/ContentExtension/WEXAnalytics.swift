//
//  WEXAnalytics.swift
//  WEGExtensionApp
//
//  Created by Yogesh Singh on 29/01/20.
//  Copyright © 2020 Yogesh Singh. All rights reserved.
//

import Foundation

class WEXAnalytics {
    
    lazy var appGroup: String? = {
        
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
    }()
    
    lazy var userDefaults : UserDefaults? = {
       
        if let group = appGroup {
            return UserDefaults(suiteName: group)
        }
        
        return nil
    }()
    
//    lazy var dateFormatter : DateFormatter
    
    
    
    // MARK: - Event Helpers
    
    func trackEvent(with name: String) {
        trackEvent(with: name, and: [AnyHashable: Any]())
    }
    
    func trackEvent(with name: String, and value: [AnyHashable: Any]) {
        
        if name.hasPrefix("we_") {
            let eventName = (name as NSString).substring(from: 3)
            trackInternalEvent(with: eventName, and: value, isSystemEvent: true)
        } else {
            let eventValue = ["event_data_overrides": value]
            trackInternalEvent(with: name, and: eventValue, isSystemEvent: false)
        }
    }
    
    func trackInternalEvent(with name: String, and value: [AnyHashable: Any], isSystemEvent: Bool) {

        let key = "weg_event_" + UUID().uuidString
        
        let value = ["event_name": name, "event_value": value, "is_system": isSystemEvent] as [String : Any]

        userDefaults?.set(value, forKey: key)
    }
}


/*

 + (NSDateFormatter *)getDateFormatter {
     static NSDateFormatter *birthDateFormatter = nil;
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
         birthDateFormatter = [[NSDateFormatter alloc] init];
         [birthDateFormatter setDateFormat:@"yyyy-MM-dd"];
         [birthDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
         [birthDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"gb"]];
     });
     return birthDateFormatter;
 }

 */
