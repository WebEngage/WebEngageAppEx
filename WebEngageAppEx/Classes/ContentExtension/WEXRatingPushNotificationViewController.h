//
//  WEXRatingPushNotificationViewController.h
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "WEXRichPushNotificationViewController+Private.h"
#import "WEXRichPushLayout.h"
#endif

#define CONTENT_PADDING  10
#define TITLE_BODY_SPACE 5

@interface WEXRatingPushNotificationViewController
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
: WEXRichPushLayout
#else
: NSObject
#endif

@end
