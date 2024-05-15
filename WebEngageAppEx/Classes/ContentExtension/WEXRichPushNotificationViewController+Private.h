//
//  WEXRichPushNotificationViewController+Private.h
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXRichPushNotificationViewController.h"

@interface WEXRichPushNotificationViewController (Private)

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (NSMutableDictionary *)getActivityDictionaryForCurrentNotification;

- (void)updateActivityWithObject:(id)object forKey:(NSString *)key;

- (void)setActivityForCurrentNotification:(NSDictionary *)activity;

- (void)addSystemEventWithName:(NSString *)eventName
                    systemData:(NSDictionary *)systemData
               applicationData:(NSDictionary *)applicationData;

- (void)setCTAWithId:(NSString *)ctaId andLink:(NSString *)actionLink;

- (NSTextAlignment)naturalTextAlignmentForText:(NSString*)text;

- (NSTextAlignment)naturalTextAlignmentForText:(NSString*)text forDescription:(BOOL)forDescription;

- (NSAttributedString *)getHtmlParsedString:(NSString *)textString isTitle:(BOOL)isTitle bckColor:(NSString *)bckColor;

- (void)setExtensionDefaults;

- (NSUserDefaults *)getSharedUserDefaults;

#endif

@end
