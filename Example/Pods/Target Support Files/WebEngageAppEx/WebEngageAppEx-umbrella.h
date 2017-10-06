#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "WEGRichPushNotificationViewController.h"
#import "WEGAnalytics.h"
#import "WEGUser.h"
#import "WEGPushNotificationService.h"

FOUNDATION_EXPORT double WebEngageAppExVersionNumber;
FOUNDATION_EXPORT const unsigned char WebEngageAppExVersionString[];

