//
//  WEXRatingPushNotificationViewController.h
//  WebEngage
//
//  Created by Arpit on 04/04/17.
//  Copyright © 2017 Saumitra R. Bhave. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "WEXRichPushNotificationViewController+Private.h"
#import "WEXRichPushLayout.h"
#endif

@interface WEXRatingPushNotificationViewController
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
: WEXRichPushLayout
#else
: NSObject
#endif

@end
