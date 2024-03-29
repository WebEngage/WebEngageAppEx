//
//  WEXTextPushNotificationViewController.h
//  WebEngage
//
//  Copyright (c) 2022 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "WEXRichPushNotificationViewController+Private.h"
#import "WEXRichPushLayout.h"
#endif

@interface WEXTextPushNotificationViewController
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
: WEXRichPushLayout
#else
: NSObject
#endif

@end
