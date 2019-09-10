//
//  WEXPushNotificationService.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import <WebEngageAppEx/WEXAnalytics.h>

#import "WEXPushNotificationService.h"


@interface WEXPushNotificationService ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic) UNMutableNotificationContent *bestAttemptContent;
#endif

@end


@implementation WEXPushNotificationService

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000


#pragma mark - Service Extension Delegates

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSLog(@"Push Notification content: %@", request.content.userInfo);
    
    NSDictionary *expandableDetails = request.content.userInfo[@"expandableDetails"];
    
    NSString *style = expandableDetails[@"style"];
    
    if (expandableDetails && style && [style isEqualToString:@"CAROUSEL_V1"]) {
        
        [self drawCarouselViewWith:expandableDetails[@"items"]];
    }
    else if (expandableDetails && style &&
             ([style isEqualToString:@"RATING_V1"] || [style isEqualToString:@"BIG_PICTURE"])) {
        
        [self drawBannerViewWith:expandableDetails[@"image"]];
    }
    else {
        [self trackEventWithCompletion:^{
            self.contentHandler(self.bestAttemptContent);
        }];
    }
}

- (void)serviceExtensionTimeWillExpire {
    NSLog(@"%@", @(__FUNCTION__));
    self.contentHandler(self.bestAttemptContent);
}


#pragma mark - View Helpers

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


#pragma mark - Network Helpers

- (void)fetchAttachmentFor:(NSString *)urlString
                        at:(NSUInteger)index
         completionHandler:(void (^)(UNNotificationAttachment *, NSUInteger))completionHandler {
    
    NSString *fileExt = [@"." stringByAppendingString:urlString.pathExtension];
    
    [[[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:urlString]
                                     completionHandler:^(NSURL *temporaryFileLocation,  NSURLResponse *response, NSError *error) {
                                         
         UNNotificationAttachment *attachment = nil;
         
         if (error != nil) {
             NSLog(@"%@", error);
         } else {
             
             NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
             
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

- (void)trackEventWithCompletion:(void(^)(void))completion {
    
    NSURLRequest *request = [self getRequestForTracker];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"Could not log push_notification_view event with error: %@", error);
        }
        else {
            NSLog(@"URLResponse: %@", response);
        }

        if (completion) {
            completion();
        }
    }] resume];
}

- (NSURLRequest *)getRequestForTracker {
    
    NSURL *url = [NSURL URLWithString:@"https://c.webengage.com/tracker"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/transit+json" forHTTPHeaderField:@"Content-type"];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *str = @"{\"license_code\":\"311c5607\",\"interface_id\":\"com.WebEngageExampleSwift|7304B686-39DD-4A9A-AB42-216D276FC569\",\"suid\":null,\"luid\":null,\"cuid\":null,\"category\":\"system\",\"event_name\":\"push_notification_view\",\"event_time\":\"~t2019-07-20T00:00:00.000Z\",\"event_data\":{},\"system_data\":{\"sdk_id\":3,\"sdk_version\":3333,\"app_id\":\"com.webengage.testapp1\",\"experiment_id\":\"~~848i0||~3290i1d8e12a56i_56c907ca-db7b-441f-8073-2d5170c27620#8:1566988938000\",\"id\":\"5n81eg4\"}}";
    
    request.HTTPBody = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    return request;
}

#endif

@end
