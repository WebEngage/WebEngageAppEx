//
//  WEXRichPushNotificationViewController.swift
//  ContentExtension
//
//  Created by Yogesh Singh on 19/12/19.
//  Copyright © 2019 Yogesh Singh. All rights reserved.
//

import UIKit
import os.log
import UserNotificationsUI


class WEXRichPushNotificationViewController: UIViewController {
    
    var isRendering = false
    let analytics = WEXAnalytics()
    var notification: UNNotification?
    var controller: UNNotificationContentExtension?
    
    
    // MARK: - View Helpers
    
    func getController(for notification: UNNotification) -> UNNotificationContentExtension? {
        
        guard
            let expandableDetails = notification.request.content.userInfo["expandableDetails"] as? [AnyHashable: Any],
            let style = expandableDetails["style"] as? String
        else {
            os_log("Could not parse notification correctly: %{public}@", log: .default, type: .error, notification.request.content.userInfo)
            return nil
        }
        
        switch style {
        case "CAROUSEL_V1":
            return WEXCarouselPushNotificationViewController()
            
        case "RATING_V1":
            return WEXRatingPushNotificationViewController()
            
        default:
            os_log("Incorrect style parameter encountered: %{public}@", log: .default, type: .error, style)
            return nil
        }
    }
    
    
    // MARK: - Notification Activity Data
    
    func getActivity() -> [AnyHashable: Any]? {
        
        guard
            let notification = notification,
            let expID = notification.request.content.userInfo["experiment_id"] as? String,
            let notifID = notification.request.content.userInfo["notification_id"] as? String,
            let expandableDetails = notification.request.content.userInfo["expandableDetails"],
            let userDefaults = analytics.userDefaults
        else {
            return nil
        }
        
        let finalNotifID = expID + "|" + notifID

        if let dictionary = userDefaults.dictionary(forKey: finalNotifID) {
            return dictionary
        } else {
           
            var dictionary = [AnyHashable: Any]()
            dictionary["experiment_id"] = expID
            dictionary["notification_id"] = notifID
            dictionary["expandableDetails"] = expandableDetails
            
            if let customData = notification.request.content.userInfo["customData"] {
                dictionary["customData"] = customData
            }
            
            return dictionary
        }
    }
    
    func setActivity(for activity: [AnyHashable: Any]) {
        
        guard
            let notification = notification,
            let expID = notification.request.content.userInfo["experiment_id"] as? String,
            let notifID = notification.request.content.userInfo["notification_id"] as? String,
            let userDefaults = analytics.userDefaults
        else {
            return
        }
        
        let finalNotifID = expID + "|" + notifID
        
        userDefaults.set(activity, forKey: finalNotifID)
    }
    
    func updateActivity(object: Any, key: String) {
        
        if var activity = getActivity() {
            
            activity[key] = object
            
            setActivity(for: activity)
        }
    }
}


// MARK: - Content Extension Delegates

extension WEXRichPushNotificationViewController: UNNotificationContentExtension {
    
    func didReceive(_ notification: UNNotification) {
        
        isRendering = true
        self.notification = notification
        
        updateActivity(object: false, key: "collapsed")
        updateActivity(object: true, key: "expanded")
        
        if let controller = getController(for: notification) {
            self.controller = controller
            controller.didReceive(notification)
        }
    }
    
    func didReceive(_ response: UNNotificationResponse,
                    completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        controller?.didReceive?(response, completionHandler: completion)
    }
}


/*
 
 - (void)addSystemEventWithName:(NSString *)eventName
                     systemData:(NSDictionary *)systemData
                applicationData:(NSDictionary *)applicationData {
     
     [self addEventWithName:eventName
                 systemData:systemData
            applicationData:applicationData
                   category:@"system"];
 }

 - (void)addEventWithName:(NSString *)eventName
               systemData:(NSDictionary *)systemData
          applicationData:(NSDictionary *)applicationData
                 category:(NSString *)category {
     
     id customData = self.notification.request.content.userInfo[@"customData"];
     
     NSMutableDictionary *customDataDictionary = [[NSMutableDictionary alloc] init];
     
     if (customData && [customData isKindOfClass:[NSArray class]]) {
         NSArray *customDataArray = customData;
         for (NSDictionary *customDataItem in customDataArray) {
             customDataDictionary[customDataItem[@"key"]] = customDataItem[@"value"];
         }
     }
     
     if (applicationData) {
         [customDataDictionary addEntriesFromDictionary:applicationData];
     }
     
     if ([category isEqualToString:@"system"]) {
         [WEXAnalytics trackEventWithName:[@"we_" stringByAppendingString:eventName]
                                 andValue:@{
                                             @"system_data_overrides": systemData ? systemData : @{},
                                             @"event_data_overrides": customDataDictionary
                                         }];
     } else {
         [WEXAnalytics trackEventWithName:eventName andValue:customDataDictionary];
     }
 }

 - (void)setCTAWithId:(NSString *)ctaId andLink:(NSString *)actionLink {
     
     NSDictionary *cta = @{@"id": ctaId, @"actionLink": actionLink};
     
     [self updateActivityWithObject:cta forKey:@"cta"];
 }

 - (NSTextAlignment)naturalTextAligmentForText:(NSString*) text{
     NSArray *tagschemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeLanguage, nil];
     NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagschemes options:0];
     [tagger setString:text];
     NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
     if ([language rangeOfString:@"he"].location != NSNotFound || [language rangeOfString:@"ar"].location != NSNotFound) {
         return NSTextAlignmentRight;
     } else {
         return NSTextAlignmentLeft;
     }
 }
 
 */
