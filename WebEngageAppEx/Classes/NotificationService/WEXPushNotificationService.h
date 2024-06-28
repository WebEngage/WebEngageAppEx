//
//  WEXPushNotificationService.h
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WENetworkResponse.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
#import <UserNotifications/UserNotifications.h>
#endif


/**
 *  This class is an encapsulation for managing handling prerequisites for
 *  custom content rich push notifications sent using WebEngage. This class
 *  should only be used by extending NotificationService class created as part
 *  of the Notification Service Extension and should not be instantiated as such.
 */
@interface WEXPushNotificationService
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
: UNNotificationServiceExtension
#else
: NSObject
#endif

- (BOOL)handleNetworkInterceptor;

- (void)onRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler;

- (void)onResponse:(WENetworkResponse *)response completionHandler:(void (^)(WENetworkResponse *))completionHandler;

- (instancetype)initWithNotificationDelegate:(UNNotificationServiceExtension *)notificationDelegate;
- (instancetype)init;
@end

