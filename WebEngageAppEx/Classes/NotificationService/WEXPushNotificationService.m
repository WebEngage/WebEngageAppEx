//
//  WEXPushNotificationService.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXPushNotificationService.h"

@interface WEXPushNotificationService ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic) UNMutableNotificationContent *bestAttemptContent;
#endif

@end


@implementation WEXPushNotificationService

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

#pragma mark - Extension Delegates

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    NSDictionary *expandableDetails = request.content.userInfo[@"expandableDetails"];
    
    NSLog(@"Push Notification content: %@", request.content.userInfo);
    
    NSString *style = expandableDetails[@"style"];
    
    if (expandableDetails && style && [style isEqualToString:@"CAROUSEL_V1"]) {
        
        NSArray *carouselItems = expandableDetails[@"items"];
        
        NSMutableArray *attachmentsArray = [[NSMutableArray alloc] initWithCapacity:carouselItems.count];
        
        if (carouselItems.count >= 3) {
            
            NSUInteger counter = 0;
            NSUInteger __block imageDownloadAttemptCounter = 0;
            
            for (NSDictionary *carouselItem in carouselItems) {
                
                NSString *imageURL = carouselItem[@"image"];
                
                [self loadAttachmentForUrlString:imageURL
                                         atIndex:counter
                               completionHandler:^(UNNotificationAttachment *attachment, NSUInteger idx) {
                                   
                                   imageDownloadAttemptCounter++;
                                   
                                   if (attachment) {
                                       [attachmentsArray addObject:attachment];
                                       self.bestAttemptContent.attachments = attachmentsArray;
                                   }
                                   
                                   if (imageDownloadAttemptCounter == carouselItems.count) {
                                       self.contentHandler(self.bestAttemptContent);
                                   }
                               }];
                counter++;
            }
        }
    } else if (expandableDetails && style &&
               ([style isEqualToString:@"RATING_V1"] ||
                [style isEqualToString:@"BIG_PICTURE"])) {
                   
                   NSString *urlStr = expandableDetails[@"image"];
                   
                   [self loadAttachmentForUrlString:urlStr
                                            atIndex:0
                                  completionHandler:^(UNNotificationAttachment *attachment, NSUInteger idx) {
                                      
                                      if (attachment) {
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


#pragma mark - Network Helper

- (void)loadAttachmentForUrlString:(NSString *)urlString
                           atIndex:(NSUInteger)idx
                 completionHandler:(void (^)(UNNotificationAttachment *, NSUInteger))completionHandler {
    
    NSString *fileExt = [@"." stringByAppendingString:[urlString pathExtension]];
    
    [[[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:urlString]
                                     completionHandler:^(NSURL *temporaryFileLocation,  NSURLResponse *response, NSError *error) {
                                         
         UNNotificationAttachment *attachment;
                                         
         if (error) {
             NSLog(@"%@", error);
         }
         else {
             
             NSFileManager *fileManager = [NSFileManager defaultManager];
             
             NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
             
             [fileManager moveItemAtURL:temporaryFileLocation
                                  toURL:localURL
                                  error:&error];
             
             NSError *attachmentError = nil;
             
             attachment = [UNNotificationAttachment attachmentWithIdentifier:[NSString stringWithFormat:@"%ld",(unsigned long)idx]
                                                                         URL:localURL
                                                                     options:nil
                                                                       error:&attachmentError];
             
             if (attachmentError) {
                 NSLog(@"%@", attachmentError);
             }
         }
         
         NSLog(@"Sending Callback");
         completionHandler(attachment, idx);
                                         
     }] resume];
}

#endif

@end

