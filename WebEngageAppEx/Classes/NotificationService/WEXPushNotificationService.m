//
//  WEXPushNotificationService.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXPushNotificationService.h"
#import <UserNotifications/UserNotifications.h>


@interface WEXPushNotificationService ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic) NSString *enviroment;
@property NSDictionary<NSString *, NSString *> *sharedUserDefaults;
@property NSArray *bannerCategories;
#endif

@end


@implementation WEXPushNotificationService

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000


#pragma mark - Service Extension Delegates

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    self.bannerCategories = @[@"WEG_BANNER_V1", @"WEG_BANNER_V2", @"WEG_BANNER_V3", @"WEG_BANNER_V4", @"WEG_BANNER_V5", @"WEG_BANNER_V6", @"WEG_BANNER_V7", @"WEG_BANNER_V8"];
    [self setExtensionDefaults];
    
    NSLog(@"Push Notification content: %@", request.content.userInfo);
    
    NSDictionary *expandableDetails = request.content.userInfo[@"expandableDetails"];
    
    NSString *style = expandableDetails[@"style"];
    
    if (expandableDetails && style && [style isEqualToString:@"CAROUSEL_V1"]) {
        [self drawCarouselViewWith:expandableDetails[@"items"]];
        
    } else if (expandableDetails && style && [style isEqualToString:@"RATING_V1"]) {
        [self drawBannerViewWith:expandableDetails[@"image"]];
    
    } else if (expandableDetails && style && [style isEqualToString:@"BIG_PICTURE"]) {
        NSString *bannerCatName = [self getBannerCategoryFor:self.bestAttemptContent.categoryIdentifier];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *existingCategories) {
            UNNotificationCategory *currentCategory;
            BOOL isBannerRegistered = NO;
            BOOL isCurrentCatBanner = NO;
            NSMutableSet *existingMutablecat = [[NSMutableSet alloc] init];
            
            for(UNNotificationCategory *dict in existingCategories) {
                if([dict.identifier isEqual: self.bestAttemptContent.categoryIdentifier]) {
                    currentCategory = dict;
                    isBannerRegistered = [dict.identifier isEqualToString:bannerCatName];
                    isCurrentCatBanner = [self.bannerCategories containsObject:dict.identifier];
                } else {
                    [existingMutablecat addObject:dict];
                }
            }
            
            if (isBannerRegistered) {
                if (!isCurrentCatBanner) {
                    [self.bestAttemptContent setCategoryIdentifier:bannerCatName];
                }
                [self drawBannerViewWith:expandableDetails[@"image"]];
                return;
            }
            
            // Register banner layout here.
            NSMutableArray *actions = [NSMutableArray arrayWithCapacity:currentCategory.actions.count];
            
            for (UNNotificationAction *action in currentCategory.actions) {
                UNNotificationAction *actionObject = [UNNotificationAction actionWithIdentifier:action.identifier
                                                                                          title:action.title
                                                                                        options:action.options];
                [actions addObject:actionObject];
            }
            
            UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:bannerCatName
                                                                                      actions:actions
                                                                            intentIdentifiers:@[]
                                                                                      options:UNNotificationCategoryOptionCustomDismissAction];
            [existingMutablecat addObject:category];
            [center setNotificationCategories:existingMutablecat];
            [self.bestAttemptContent setCategoryIdentifier:bannerCatName];
            /*
             Dispatching on Main thread after 2 sec delay to make sure our category is registered with NotificationCenter
             Registering will make sure, contentHandler will invoke ContentExtension with this custom category
             
             NOTE: Use this workaround till we receive banner category in network response.
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self drawBannerViewWith:expandableDetails[@"image"]];
            });
        }];
        
    } else {
        [self trackEventWithCompletion:^{
            self.contentHandler(self.bestAttemptContent);
        }];
    }
}

// NOTE: This mapping is a temporary workaround, Will be removed in future releases

- (NSString *)getBannerCategoryFor:(NSString *)currentCategory {
    NSDictionary *bannerMapping = @{
        @"default" : self.bannerCategories[0],
        @"18dfbbcc" : self.bannerCategories[1],
        @"16589g0g" : self.bannerCategories[2],
        @"15ead296" : self.bannerCategories[3],
        @"17543720" : self.bannerCategories[4],
        @"16e66ba8" : self.bannerCategories[5],
        @"1c406g7a" : self.bannerCategories[6],
        @"1bd2a2g0" : self.bannerCategories[7]
    };
    
    NSString *category = bannerMapping[currentCategory];
    if (category) {
        return category;
    } else {
        return currentCategory;
    }
}

- (void)setExtensionDefaults {
    NSUserDefaults *sharedDefaults = [self getSharedUserDefaults];
    // Write operation only if key is not present in the UserDefaults
    
    if ([sharedDefaults valueForKey:@"WEG_ServiceToApp"] == nil) {
        [sharedDefaults setValue:@"WEG" forKey:@"WEG_ServiceToApp"];
        [sharedDefaults synchronize];
    }
}

- (void)serviceExtensionTimeWillExpire {
    NSLog(@"%@", @(__FUNCTION__));
    self.contentHandler(self.bestAttemptContent);
}


#pragma mark - Rich Push View Helpers

- (void)drawCarouselViewWith:(NSArray *)items {
    
    NSMutableArray *attachmentsArray = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    if (items.count >= 3) {
        NSUInteger itemCounter = 0;
        NSUInteger __block imageDownloadAttemptCounter = 0;
        
        for (NSDictionary *carouselItem in items) {
            
            NSString *imageURL = carouselItem[@"image"];
            
            [self fetchAttachmentFor:imageURL
                                  at:itemCounter
                   completionHandler:^(UNNotificationAttachment *attachment, NSUInteger index) {
                
                imageDownloadAttemptCounter++;
                
                if (attachment) {
                    NSLog(@"Downloaded Attachment No. %ld", (unsigned long)index);
                    [attachmentsArray addObject:attachment];
                    self.bestAttemptContent.attachments = attachmentsArray;
                }
                
                if (imageDownloadAttemptCounter == items.count) {
                    
                    [self trackEventWithCompletion:^{
                        NSLog(@"Ending WebEngage Rich Push Service");
                        self.contentHandler(self.bestAttemptContent);
                    }];
                }
            }];
            itemCounter++;
        }
    }
}

- (void)drawBannerViewWith:(NSString *)urlStr {
    
    [self fetchAttachmentFor:urlStr
                          at:0
           completionHandler:^(UNNotificationAttachment *attachment, NSUInteger index) {
        
        if (attachment) {
            NSLog(@"WebEngage Downloaded Image for Rating Layout");
            self.bestAttemptContent.attachments = @[ attachment ];
        }
        
        [self trackEventWithCompletion:^{
            self.contentHandler(self.bestAttemptContent);
        }];
    }];
}

- (void)fetchAttachmentFor:(NSString *)urlString
                        at:(NSUInteger)index
         completionHandler:(void (^)(UNNotificationAttachment *, NSUInteger))completionHandler {
    
    NSString *fileExt = [@"." stringByAppendingString:urlString.pathExtension];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    NSDictionary *headers = @{
        @"Accept": @"image/webp"
    };
    
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session downloadTaskWithRequest:request
                    completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
        
        UNNotificationAttachment *attachment = nil;
        if (error != nil) {
            NSLog(@"%@", error);
        } else {
            
            NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
            NSLog(@"SIZE FOR THE FILE %lld",response.expectedContentLength);
            
            NSError *moveError;
            [[NSFileManager defaultManager] moveItemAtURL:temporaryFileLocation
                                                    toURL:localURL
                                                    error:&moveError];
            
            if (moveError) {
                NSLog(@"File Move Error: %@", moveError);
            }
            
            NSError *attachmentError;
            
            attachment = [UNNotificationAttachment attachmentWithIdentifier:[NSString stringWithFormat:@"%ld",(unsigned long)index] URL:localURL options:nil error:&attachmentError];
            
            if (attachmentError) {
                NSLog(@"%@", attachmentError);
            }
        }
        
        NSLog(@"Sending Callback");
        
        completionHandler(attachment, index);
        
    }] resume];
}


#pragma mark - Tracker Event Helpers

- (void)trackEventWithCompletion:(void(^)(void))completion {
    
    NSURLRequest *request = [self getRequestForTracker];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Could not log push_notification_view event with error: %@", error);
        }
        else {
            NSLog(@"Push Tracker URLResponse: %@", response);
        }
        
        if (completion) {
            completion();
        }
    }] resume];
}

- (NSString *) getBaseURL{
    NSString *baseURL = @"https://c.webengage.com/tracker";
    
    [self setDataFromSharedUserDefaults];
    
    NSLog(@"Setting Enviroment to : %@",self.enviroment);
    
    if ([self.enviroment.uppercaseString isEqualToString:@"IN"]) {
        baseURL = @"https://c.in.webengage.com/tracker";
    }
    else if ([self.enviroment.uppercaseString isEqualToString:@"IR0"]) {
        baseURL = @"https://c.ir0.webengage.com/tracker";
    }
    else if ([self.enviroment.uppercaseString isEqualToString:@"UNL"]) {
        baseURL = @"https://c.unl.webengage.com/tracker";
    }
    
    return baseURL;
}

- (NSURLRequest *)getRequestForTracker {
    
    NSURL *url = [NSURL URLWithString:[self getBaseURL]];
    
    NSLog(@"Base url: %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/transit+json" forHTTPHeaderField:@"Content-type"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    request.HTTPBody = [self getTrackerRequestBody];
    
    return request;
}

- (NSData *)getTrackerRequestBody {
    
    NSDictionary *userDefaultsData = self.sharedUserDefaults;
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    body[@"event_name"] = @"push_notification_view";
    body[@"category"] = @"system";
    body[@"suid"] = @"null";
    body[@"luid"] = @"null";
    body[@"cuid"] = @"null";
    body[@"event_time"] = [self getCurrentFormattedTime];
    body[@"license_code"] = userDefaultsData[@"license_code"];
    body[@"interface_id"] = userDefaultsData[@"interface_id"];
    
    // Passing custom data into event tracking
    id customData = self.bestAttemptContent.userInfo[@"customData"];
    
    if (customData && [customData isKindOfClass:[NSArray class]]) {
        NSArray *customDataArray = (NSArray *)customData;
        
        NSMutableDictionary *customDataDictionary = [[NSMutableDictionary alloc]
                                                     initWithCapacity:customDataArray.count];
        
        for (NSDictionary *customDataItem in customDataArray) {
            if (customDataItem[@"key"] && [customDataItem[@"key"] isKindOfClass:[NSString class]]) {
                customDataDictionary[customDataItem[@"key"]] =
                customDataItem[@"value"];
            }
        }
        
        body[@"event_data"] = customDataDictionary;
    } else {
        body[@"event_data"] = @{};
    }
    
    NSMutableDictionary *systemData = [NSMutableDictionary dictionary];
    systemData[@"sdk_id"] = @(3);
    systemData[@"sdk_version"] = [NSNumber numberWithInteger:[userDefaultsData[@"sdk_version"] integerValue]];
    systemData[@"app_id"] = userDefaultsData[@"app_id"];
    systemData[@"experiment_id"] = self.bestAttemptContent.userInfo[@"experiment_id"];
    systemData[@"id"] = self.bestAttemptContent.userInfo[@"notification_id"];
    
    body[@"system_data"] = systemData;
    
    body = [self dictionaryOfProperties:body];
    
    NSLog(@"Data reporting to tracker: %@",body);
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"Error in converting data: %@", error);
    }
    
    return data;
}

- (id)dictionaryOfProperties:(id)property {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)property];
    [d enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id sanitizedObj = [self sanitizeForTransit:obj];
        if ([sanitizedObj isKindOfClass:[NSDictionary class]]) {
            sanitizedObj = [self dictionaryOfProperties:obj];
        }
        [d setValue:sanitizedObj forKey:key];
    }];
    return d;
}

- (id)sanitizeForTransit:(id)obj {
    
    if ([obj isKindOfClass:[NSString class]]) {
        if (([obj hasPrefix:@"~"] || [obj hasPrefix:@"^"] || [obj hasPrefix:@"`"]) && ![obj hasPrefix:@"~t"]) {
            obj = [@"~" stringByAppendingString:obj];
        }
        
        if ([obj isEqualToString:@"null"]) {
            obj = [NSNull null];
        }
    }
    
    return obj;
}

- (NSString *)getCurrentFormattedTime {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"'~t'yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"gb"];
    return [formatter stringFromDate:[NSDate date]];
}

- (void)setDataFromSharedUserDefaults {
    
    NSUserDefaults *defaults = [self getSharedUserDefaults];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    data[@"license_code"] = [defaults objectForKey:@"license_code"];
    data[@"interface_id"] = [defaults objectForKey:@"interface_id"];
    data[@"sdk_version"] =  [NSNumber numberWithInteger:[[defaults objectForKey:@"sdk_version"] integerValue]];
    data[@"app_id"] = [defaults objectForKey:@"app_id"];
    
    self.sharedUserDefaults = data;
    
    NSLog(@"Environment: %@",[defaults objectForKey:@"environment"]);
    self.enviroment = [defaults objectForKey:@"environment"];
    
}

- (NSUserDefaults *)getSharedUserDefaults {
    
    NSString *appGroup = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEX_APP_GROUP"];
    
    if (!appGroup) {
        NSBundle *bundle = [NSBundle mainBundle];
        
        if ([[bundle.bundleURL pathExtension] isEqualToString:@"appex"]) {
            bundle = [NSBundle bundleWithURL:[[bundle.bundleURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent]];
        }
        
        NSString *bundleIdentifier = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        
        appGroup = [NSString stringWithFormat:@"group.%@.WEGNotificationGroup", bundleIdentifier];
    }
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
    
    if (!defaults) {
        NSLog(@"Shared User Defaults could not be initialized. Ensure Shared App Groups have been enabled on Main App & Notification Service Extension Targets.");
    }
    
    return defaults;
}

#endif

@end
