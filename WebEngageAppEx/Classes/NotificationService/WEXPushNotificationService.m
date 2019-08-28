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

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    UNNotificationContent *content = request.content;
    NSDictionary *expandableDetails = content.userInfo[@"expandableDetails"];
    
    NSLog(@"Push Notification content: %@", request.content.userInfo);
    
    NSString *style = expandableDetails[@"style"];
    
    if (expandableDetails && style && [style isEqualToString:@"CAROUSEL_V1"]) {
        
        NSArray *carouselItems = expandableDetails[@"items"];
        
        NSMutableArray *attachmentsArray = [[NSMutableArray alloc] initWithCapacity:carouselItems.count];
        
        if (carouselItems.count >= 3) {
            
            NSUInteger itemCounter = 0;
            NSUInteger __block imageDownloadAttemptCounter = 0;
            
            for (NSDictionary *carouselItem in carouselItems) {
                
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
                           
                           if (imageDownloadAttemptCounter == carouselItems.count) {
                               NSLog(@"Ending WebEngage Rich Push Service");
                               self.contentHandler(self.bestAttemptContent);
                           }
                       }];
                itemCounter++;
            }
        }
    } else if (expandableDetails && style &&
               ([style isEqualToString:@"RATING_V1"] ||
                [style isEqualToString:@"BIG_PICTURE"])) {
                   
                   NSString *urlStr = expandableDetails[@"image"];
                   
                   [self fetchAttachmentFor:urlStr
                                         at:0
                          completionHandler:^(UNNotificationAttachment *attachment, NSUInteger index) {
                              
                              if (attachment) {
                                  NSLog(@"WebEngage Downloaded Image for Rating Layout");
                                  self.bestAttemptContent.attachments = @[ attachment ];
                              }
                              
                              self.contentHandler(self.bestAttemptContent);
                          }];
               } else {
                   self.contentHandler(self.bestAttemptContent);
               }
}

- (void)serviceExtensionTimeWillExpire {
    
    self.contentHandler(self.bestAttemptContent);
}

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

#endif

@end

