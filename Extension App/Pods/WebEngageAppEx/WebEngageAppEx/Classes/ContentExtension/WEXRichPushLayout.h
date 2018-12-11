//
//  WEXRichPushLayout.h
//  WebEngage
//
//  Created by Arpit on 13/04/17.
//  Copyright © 2017 Saumitra R. Bhave. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#endif
#import "WEXRichPushNotificationViewController.h"


@interface WEXRichPushLayout
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
: NSObject<UNNotificationContentExtension>

@property(nonatomic, strong, readonly) UIView* view;
@property(nonatomic, strong, readonly) WEXRichPushNotificationViewController* viewController;

-(instancetype) initWithNotificationViewController: (WEXRichPushNotificationViewController*) viewController;
#else
: NSObject
#endif

@end
