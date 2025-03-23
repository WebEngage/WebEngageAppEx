//
//  WEXPushNotificationService.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXPushNotificationService.h"
#import <UserNotifications/UserNotifications.h>

#define WEX_SERVICE_EXTENSION_VERSION @"1.3.1"
#define WEX_TRACK_IP_LOCATION @"WEGTrackIPLocation"
#define WEX_PROXY_URL @"proxy_url"
#define WEX_LICENSE_CODE @"license_code"
#define WEX_INTERFACE_ID @"interface_id"
#define WEX_SDK_VERSION @"sdk_version"
#define WEX_APP_ID @"app_id"
#define WEX_ENVIRONMENT @"environment"
#define WEX_EXPANDABLE_DETAILS @"expandableDetails"

@interface WEXPushNotificationService ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic) NSString *enviroment;
@property NSString *serviceExtensionVersion;
@property NSDictionary<NSString *, NSString *> *sharedUserDefaults;
@property NSArray *customCategories;
@property (nonatomic, strong) UNNotificationServiceExtension *notificationDelegate;

#endif

@end


@implementation WEXPushNotificationService

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000


#pragma mark - Service Extension Delegates

/// Initializes the service extension handler with a notification delegate.
/// - Parameter notificationDelegate: The delegate handling the notification service extension.
/// - Returns: An initialized instance of the handler.
- (instancetype)initWithNotificationDelegate:(UNNotificationServiceExtension *)notificationDelegate {
    self = [super init];
    if (self) {
        _notificationDelegate = notificationDelegate;
    }
    return self;
}

/// Default initializer for the service extension handler.
/// - Returns: An initialized instance of the handler.
- (instancetype)init {
    self = [super init];
    if (self) {
        _notificationDelegate = nil;
    }
    return self;
}

/// Processes the received notification request and modifies its content accordingly.
/// - Parameters:
///   - request: The notification request received.
///   - contentHandler: The completion handler to be called after processing.
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    if([request.content.userInfo[@"source"] isEqualToString:@"webengage"]) {
        self.contentHandler = contentHandler;
        self.bestAttemptContent = [request.content mutableCopy];
        [self setExtensionDefaults];
        
        NSLog(@"Push Notification content: %@", request.content.userInfo);
        
        NSDictionary *expandableDetails = request.content.userInfo[WEX_EXPANDABLE_DETAILS];
        NSString *style = expandableDetails[@"style"];
        
        if (expandableDetails && style && [style isEqualToString:@"CAROUSEL_V1"]) {
            [self drawCarouselViewWith:expandableDetails[@"items"]];
            
        } else if (expandableDetails && style && [style isEqualToString:@"RATING_V1"]) {
            [self handleContentFor:style image:expandableDetails[@"image"]];
            
        } else if (expandableDetails && style && ([style isEqualToString:@"BIG_PICTURE"] || [style isEqualToString:@"BIG_TEXT"] || [style isEqualToString:@"OVERLAY"])) {
            self.customCategories = @[@"WEG_RICH_V1", @"WEG_RICH_V2", @"WEG_RICH_V3", @"WEG_RICH_V4", @"WEG_RICH_V5", @"WEG_RICH_V6", @"WEG_RICH_V7", @"WEG_RICH_V8"];
            NSString *customCategory = [self getCategoryFor:self.customCategories currentCategory:self.bestAttemptContent.categoryIdentifier];
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            
            [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *existingCategories) {
                UNNotificationCategory *currentCategory;
                BOOL isCategoryRegistered = NO;
                BOOL isCurrentCatCustom = NO;
                NSMutableSet *existingMutablecat = [[NSMutableSet alloc] init];
                
                for(UNNotificationCategory *dict in existingCategories) {
                    if([dict.identifier isEqual: self.bestAttemptContent.categoryIdentifier]) {
                        currentCategory = dict;
                        isCategoryRegistered = [dict.identifier isEqualToString:customCategory];
                        isCurrentCatCustom = [self.customCategories containsObject:dict.identifier];
                    } else {
                        [existingMutablecat addObject:dict];
                    }
                }
                
                if (isCategoryRegistered) {
                    if (!isCurrentCatCustom) {
                        [self.bestAttemptContent setCategoryIdentifier:customCategory];
                    }
                    [self handleContentFor:style image:expandableDetails[@"image"]];
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
                
                UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:customCategory
                                                                                          actions:actions
                                                                                intentIdentifiers:@[]
                                                                                          options:UNNotificationCategoryOptionCustomDismissAction];
                [existingMutablecat addObject:category];
                [center setNotificationCategories:existingMutablecat];
                [self.bestAttemptContent setCategoryIdentifier:customCategory];
                /*
                 Dispatching on Main thread after 2 sec delay to make sure our category is registered with NotificationCenter
                 Registering will make sure, contentHandler will invoke ContentExtension with this custom category
                 
                 NOTE: Use this workaround till we receive banner category in network response.
                 */
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self handleContentFor:style image:expandableDetails[@"image"]];
                });
            }];
            
        } else {
            [self handleContentFor:style image:@""];
        }
    }
}

/// Handles the notification content based on its style and associated image.
/// - Parameters:
///   - style: The style of the notification.
///   - image: The image URL to be processed if applicable.
- (void)handleContentFor:(NSString *)style image:(NSString *)image {
    if (([style isEqualToString:@"BIG_PICTURE"] || [style isEqualToString:@"RATING_V1"] || [style isEqualToString:@"OVERLAY"]) && image) {
        [self drawBannerViewWith:image];
    } else {
        [self trackEventWithCompletion:^{
            self.contentHandler(self.bestAttemptContent);
        }];
    }
}


/// Called when the service extension is about to expire.
/// Ensures that the content handler is invoked before termination.
- (void)serviceExtensionTimeWillExpire {
    NSLog(@"%@", @(__FUNCTION__));
    self.contentHandler(self.bestAttemptContent);
}

// NOTE: This mapping is a temporary workaround, Will be removed in future releases

/// Retrieves the mapped category for the given current category.
/// - Parameters:
///   - categories: An array of category identifiers.
///   - currentCategory: The category identifier to map.
/// - Returns: The mapped category if found, otherwise returns the original category.
- (NSString *)getCategoryFor:(NSArray *)categories currentCategory:(NSString *)currentCategory {
    NSDictionary *categoryMapping = @{
        @"default" : categories[0], // Default, No buttons
        @"19db52de": categories[0], // Default, No buttons
        @"18dfbbcc": categories[1], // Yes/No - Open App/Dismiss
        @"16589g0g": categories[2], // Yes/No - Dismiss both
        @"15ead296": categories[3], // Accept/Decline - Open/Dismiss
        @"17543720": categories[4], // Accept/Decline - Dismiss both
        @"16e66ba8": categories[5], // Shop Now
        @"1c406g7a": categories[6], // Buy Now
        @"1bd2a2g0": categories[7]  // Download Now
    };
    
    NSString *category = categoryMapping[currentCategory];
    if (category) {
        return category;
    } else {
        return currentCategory;
    }
}

#pragma mark - Rich Push View Helpers

/// Draws a carousel view by downloading images from the provided items and attaching them to the notification content.
/// - Parameter items: An array of dictionaries containing image URLs.
- (void)drawCarouselViewWith:(NSArray *)items {
    
    NSMutableArray *attachmentsArray = [[NSMutableArray alloc] initWithCapacity:items.count];
    
    if (items.count <= 0) {
        return;
    }
    
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
            
            // Call trackEventWithCompletion after all images are processed.
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

/// Draws a banner view by downloading an image and attaching it to the notification content.
/// - Parameter urlStr: The URL string of the banner image.
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

/// Fetches an image attachment from a given URL and returns it via the completion handler.
/// - Parameters:
///   - urlString: The URL of the image to be fetched.
///   - index: The index of the attachment in the array.
///   - completionHandler: A callback with the downloaded attachment and its index.
- (void)fetchAttachmentFor:(NSString *)urlString
                        at:(NSUInteger)index
         completionHandler:(void (^)(UNNotificationAttachment *, NSUInteger))completionHandler {
    
    // Determine the file extension and ensure it's valid
    NSString *fileExt = [@"." stringByAppendingString:urlString.pathExtension];
    NSUInteger fileExtensionLength = [fileExt length];
    if ([fileExt isEqualToString:@"."] || fileExtensionLength >= 5){
        fileExt = @".jpg";
    }
    
    // Create a request for the image
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    NSDictionary *headers = @{
        @"Accept": @"image/webp"
    };
    
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPMethod:@"GET"];
    
    // Perform the image download
    NSURLSession *session = [NSURLSession sharedSession];
    [[session downloadTaskWithRequest:request
                    completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
        
        UNNotificationAttachment *attachment = nil;
        if (error != nil) {
            NSLog(@"%@", error);
        } else {
            
            // Move the downloaded file to a new location with a valid file extension
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
            
            // Create a UNNotificationAttachment from the file
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

/// Tracks predefined push notification events and logs the response.
/// - Parameter completion: A completion block executed after event tracking is completed.
- (void)trackEventWithCompletion:(void(^)(void))completion {
    NSArray *events = @[@"push_notification_received", @"push_notification_view"];
    
    for (NSString *event in events) {
        __block NSMutableURLRequest *request = [self getRequestForTracker:event];
        id interceptor = self.notificationDelegate ? self.notificationDelegate : self;
        
        // Configure proxy and IP tracking settings
        [self configureProxyURL:request];
        [self configureIPTrackingForRequest:request enabled:_sharedUserDefaults[WEX_TRACK_IP_LOCATION]];
        
        // Intercept and modify the request if needed
        [interceptor onRequest:request completionHandler:^(NSMutableURLRequest* modifiedRequest) {
            request = modifiedRequest;
            
            // Perform network request
            [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                             completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                __block WENetworkResponse *networkResponse = [WENetworkResponse createWithData:data response:response error:error];
                
                // Intercept and modify the response if needed
                [interceptor onResponse:networkResponse completionHandler:^(WENetworkResponse *modifiedResponse) {
                    networkResponse = modifiedResponse;
                    
                    if (networkResponse.error) {
                        NSLog(@"Could not log %@ event with error: %@", event, networkResponse.error);
                    } else {
                        NSLog(@"Push Tracker URLResponse: %@", networkResponse.response);
                    }
                }];
                
                // Call completion handler after processing the event
                if (completion) {
                    completion();
                }
            }] resume];
        }];
    }
}

/// Configures the request URL to use a custom proxy if specified in user defaults.
/// - Parameter request: The mutable URL request to be modified.
- (void)configureProxyURL:(NSMutableURLRequest *)request {
    NSString *customProxyURL = self.sharedUserDefaults[WEX_PROXY_URL];
    NSString *originalURLString = request.URL.absoluteString;
    
    // Return if the request already uses the proxy
    if (customProxyURL && [originalURLString containsString:customProxyURL]) {
        return;
    }
    
    // Encode the original URL
    NSString *encodedURL = [originalURLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
    if (!encodedURL) {
        return;
    }
    
    // Construct the new proxied URL
    NSString *newURLString = [NSString stringWithFormat:@"%@?url=%@", customProxyURL, encodedURL];
    NSURL *newURL = [NSURL URLWithString:newURLString];
    
    if (newURL) {
        request.URL = newURL;
    }
}

/// Initializes default values in the shared user defaults for the extension.
- (void)setExtensionDefaults {
    NSUserDefaults *sharedDefaults = [self getSharedUserDefaults];
    
    // Set default value for service-to-app communication if not already present
    if ([sharedDefaults valueForKey:@"WEG_ServiceToApp"] == nil) {
        [sharedDefaults setValue:@"WEG" forKey:@"WEG_ServiceToApp"];
        [sharedDefaults synchronize];
    }
    
    // Set the service extension version
    [sharedDefaults setValue:WEX_SERVICE_EXTENSION_VERSION forKey:@"WEG_Service_Extension_Version"];
    [sharedDefaults synchronize];
}


/// Returns the base URL for the tracker based on the current environment.
/// - Returns: A `NSString` representing the base tracker URL.
- (NSString *)getBaseURL {
    NSString *baseURL = @"https://c.webengage.com/tracker";
    
    // Load environment data from shared user defaults
    [self setDataFromSharedUserDefaults];
    
    NSLog(@"Setting Environment to: %@", self.enviroment);
    
    // Determine the correct base URL based on the environment
    if ([self.enviroment.uppercaseString isEqualToString:@"IN"]) {
        baseURL = @"https://c.in.webengage.com/tracker";
    }
    else if ([self.enviroment.uppercaseString isEqualToString:@"IR0"]) {
        baseURL = @"https://c.ir0.webengage.com/tracker";
    }
    else if ([self.enviroment.uppercaseString isEqualToString:@"UNL"]) {
        baseURL = @"https://c.unl.webengage.com/tracker";
    }else if ([self.enviroment.uppercaseString isEqualToString:@"KSA"]) {
        baseURL = @"https://c.ksa.webengage.com/tracker";
    }else if ([self.enviroment.uppercaseString isEqualToString:@"STAGING"]) {
        baseURL = @"https://c.stg.webengage.biz/tracker";
    }
    return baseURL;
}

/// Creates and returns a `NSMutableURLRequest` configured for sending an event to the tracker.
/// - Parameter eventName: The name of the event to be tracked.
/// - Returns: A `NSMutableURLRequest` ready to be sent.
- (NSMutableURLRequest *)getRequestForTracker:(NSString *)eventName {
    
    NSURL *url = [NSURL URLWithString:[self getBaseURL]];
    
    NSLog(@"Base url: %@", url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // Set request headers
    [request setValue:@"application/transit+json" forHTTPHeaderField:@"Content-type"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    // Attach the request body
    request.HTTPBody = [self getTrackerRequestBody:eventName];
  
    return request;
}

/// Generates the request body for an event to be tracked.
/// - Parameter eventName: The name of the event.
/// - Returns: A `NSData` object containing the JSON request body.
- (NSData *)getTrackerRequestBody:(NSString *)eventName {
    
    NSDictionary *userDefaultsData = self.sharedUserDefaults;
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    // Basic event details
    body[@"event_name"] = eventName;
    body[@"category"] = @"system";
    body[@"suid"] = @"null";
    body[@"luid"] = @"null";
    body[@"cuid"] = @"null";
    body[@"event_time"] = [self getCurrentFormattedTime];
    body[WEX_LICENSE_CODE] = userDefaultsData[WEX_LICENSE_CODE];
    body[@"interface_id"] = userDefaultsData[@"interface_id"];
    
    // Extract custom data from the notification payload
    id customData = self.bestAttemptContent.userInfo[@"customData"];
    
    if (customData && [customData isKindOfClass:[NSArray class]]) {
        NSArray *customDataArray = (NSArray *)customData;
        NSMutableDictionary *customDataDictionary = [[NSMutableDictionary alloc] initWithCapacity:customDataArray.count];
        
        // Convert custom data array into a dictionary format
        for (NSDictionary *customDataItem in customDataArray) {
            if (customDataItem[@"key"] && [customDataItem[@"key"] isKindOfClass:[NSString class]]) {
                customDataDictionary[customDataItem[@"key"]] = customDataItem[@"value"];
            }
        }
        
        body[@"event_data"] = customDataDictionary;
    } else {
        body[@"event_data"] = @{};
    }
    
    // System-related metadata
    NSMutableDictionary *systemData = [NSMutableDictionary dictionary];
    systemData[@"sdk_id"] = @(3);
    systemData[WEX_SDK_VERSION] = [NSNumber numberWithInteger:[userDefaultsData[WEX_SDK_VERSION] integerValue]];
    systemData[WEX_APP_ID] = userDefaultsData[WEX_APP_ID];
    systemData[WEX_ENVIRONMENT] = self.bestAttemptContent.userInfo[WEX_ENVIRONMENT];
    systemData[@"id"] = self.bestAttemptContent.userInfo[@"notification_id"];
    
    body[@"system_data"] = systemData;
    
    // Apply transformations to ensure correct format
    body = [self dictionaryOfProperties:body];
    
    NSLog(@"Data reporting to tracker: %@", body);
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"Error in converting data: %@", error);
    }
    
    return data;
}

/// Recursively processes a dictionary to ensure its properties conform to expected formats.
/// - Parameter property: The dictionary to process.
/// - Returns: A dictionary with sanitized properties.
- (id)dictionaryOfProperties:(id)property {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)property];
    
    [d enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id sanitizedObj = [self sanitizeForTransit:obj];
        
        // Recursively process nested dictionaries
        if ([sanitizedObj isKindOfClass:[NSDictionary class]]) {
            sanitizedObj = [self dictionaryOfProperties:obj];
        }
        
        [d setValue:sanitizedObj forKey:key];
    }];
    
    return d;
}

/// Sanitizes the given object for transit by applying specific transformations.
/// - Parameter obj: The object to sanitize.
/// - Returns: A sanitized version of the object.
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

/// Retrieves the current time formatted as a string.
/// - Returns: A formatted timestamp string in UTC timezone.
- (NSString *)getCurrentFormattedTime {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"'~t'yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"gb"];
    return [formatter stringFromDate:[NSDate date]];
}

/// Loads data from shared user defaults and updates the instance properties.
- (void)setDataFromSharedUserDefaults {
    NSUserDefaults *defaults = [self getSharedUserDefaults];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    data[WEX_LICENSE_CODE] = [defaults objectForKey:WEX_LICENSE_CODE];
    data[WEX_INTERFACE_ID] = [defaults objectForKey:WEX_LICENSE_CODE];
    data[WEX_SDK_VERSION] =  [NSNumber numberWithInteger:[[defaults objectForKey:WEX_SDK_VERSION] integerValue]];
    data[WEX_APP_ID] = [defaults objectForKey:WEX_APP_ID];
    data[WEX_PROXY_URL] = [defaults objectForKey:WEX_PROXY_URL];
    data[WEX_TRACK_IP_LOCATION] = @([defaults boolForKey:WEX_TRACK_IP_LOCATION]);
    self.sharedUserDefaults = data;
    
    NSLog(@"Environment: %@", [defaults objectForKey:WEX_ENVIRONMENT]);
    self.enviroment = [defaults objectForKey:WEX_ENVIRONMENT];
}

/// Retrieves the shared user defaults for the app group.
/// - Returns: An instance of `NSUserDefaults` associated with the shared app group.
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

/// Handles the network request and invokes the completion handler.
/// - Parameters:
///   - request: The mutable URL request to be processed.
///   - completionHandler: The completion handler to execute after processing.
- (void)onRequest:(NSMutableURLRequest *)request completionHandler:(void (^)(NSMutableURLRequest *))completionHandler {
    completionHandler(request);
}

/// Handles the network response and invokes the completion handler.
/// - Parameters:
///   - response: The network response received.
///   - completionHandler: The completion handler to execute after processing.
- (void)onResponse:(WENetworkResponse *)response completionHandler:(void (^)(WENetworkResponse *))completionHandler {
    completionHandler(response);
}

/// Configures IP tracking for a given request.
/// - Parameters:
///   - request: The mutable URL request.
///   - enabled: A boolean flag indicating whether IP tracking should be enabled.
- (void)configureIPTrackingForRequest:(NSMutableURLRequest *)request enabled:(BOOL)enabled {
    if (request && enabled) {
        [request setValue:@"1" forHTTPHeaderField:@"x-geo-ignore"];
    }
}


#endif

@end
