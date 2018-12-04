//
//  WEXRichPushNotificationViewController+Private.h
//  WebEngage
//
//  Created by Arpit on 29/06/17.
//  Copyright © 2017 Saumitra R. Bhave. All rights reserved.
//

#import "WEXRichPushNotificationViewController.h"

@interface WEXRichPushNotificationViewController (Private)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
-(NSMutableDictionary*) getActivityDictionaryForCurrentNotification;
-(void) updateActivityWithObject: (id) object forKey: (NSString*) key;

-(void) setActivityForCurrentNotification: (NSDictionary*) activity;

-(void) addSystemEventWithName: (NSString*) eventName
                    systemData: (NSDictionary*) systemData
               applicationData: (NSDictionary*) applicationData;

-(void) setCTAWithId: (NSString*) ctaId andLink: (NSString*) actionLink;
#endif

@end
