//
//  WEXPushNotificationService.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXPushNotificationService.h"
#import "UIImage+WebP.h"

@interface WEXPushNotificationService ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic, readwrite) NSURLSession *session;
#endif

@end


@implementation WEXPushNotificationService

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"WebEngage RichPush Service Initialized");
        self.session = [NSURLSession sharedSession];
    }
    return self;
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    UNNotificationContent *content = request.content;
    NSDictionary *expandableDetails = content.userInfo[@"expandableDetails"];
    
    NSString *style = expandableDetails[@"style"];
    
    if (expandableDetails && style && [style isEqualToString:@"CAROUSEL_V1"]) {
        
        NSUInteger __block imageDownloadAttemptCounter = 0;
        NSArray *carouselItems = expandableDetails[@"items"];
        
        NSMutableArray *attachmentsArray = [[NSMutableArray alloc] initWithCapacity:carouselItems.count];
        
        if (carouselItems.count >= 3) {
            
            NSUInteger i = 0;
            
            for (NSDictionary *carouselItem in carouselItems) {
                
                NSString *imageURL = carouselItem[@"image"];
                
                [self loadAttachmentForUrlString:imageURL
                                         atIndex:i
                               completionHandler:^(UNNotificationAttachment *attachment, NSUInteger idx) {
                                   
                                   imageDownloadAttemptCounter++;
                                   
                                   if (attachment) {
                                       NSLog(@"Downloaded Attachment No. %ld", (unsigned long)idx);
                                       [attachmentsArray addObject:attachment];
                                       self.bestAttemptContent.attachments = attachmentsArray;
                                   }
                                   
                                   if (imageDownloadAttemptCounter == carouselItems.count) {
                                       NSLog(@"Ending WebEngage Rich Push Service");
                                       self.contentHandler(self.bestAttemptContent);
                                   }
                               }];
                i++;
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
                                          NSLog(@"WebEngage Downloaded Image for Rating Layout");
                                          self.bestAttemptContent.attachments = @[ attachment ];
                                      }
                                      
                                      self.contentHandler(self.bestAttemptContent);
                                  }];
               } else {
                   // Just in case, out of some error none of the above layouts trigger the
                   // extension,
                   // notification should be delivered asap.
                   self.contentHandler(self.bestAttemptContent);
               }
}

- (void)serviceExtensionTimeWillExpire {
    
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified
    // content, otherwise the original push payload will be used.
    NSString *expId = self.bestAttemptContent.userInfo[@"experiment_id"];
    
    if (self.bestAttemptContent.attachments &&
        self.bestAttemptContent.attachments.count > 0) {
        
        NSLog(@"%@",
              [NSString stringWithFormat:@"attachment downloaded in expiration "
               @"handler for notification: %@",
               expId]);
    } else {
        NSLog(@"%@",
              [NSString stringWithFormat:@"attachment not downloaded in expiration "
               @"handler for notification: %@",
               expId]);
    }
    
    self.contentHandler(self.bestAttemptContent);
}

- (void)loadAttachmentForUrlString:(NSString *)urlString
                           atIndex:(NSUInteger)idx
                 completionHandler:(void (^)(UNNotificationAttachment *, NSUInteger))completionHandler {
    
    __block UNNotificationAttachment *attachment = nil;
    __block NSURL *attachmentURL = [NSURL URLWithString:urlString];
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithURL:attachmentURL
                                                     completionHandler:^(NSURL *temporaryFileLocation,  NSURLResponse *response, NSError *error) {
                                                         
                                                         if (error != nil) {
                                                             NSLog(@"%@", error);
                                                         } else {
                                                             
                                                             NSString *fileExt = [@"." stringByAppendingString:[urlString pathExtension]];
                                                             
                                                             if ([[urlString pathExtension] isEqualToString:@"webp"]) {
                                                                 fileExt = [@"." stringByAppendingString:@"png"];
                                                             }
                                                             
                                                             NSFileManager *fileManager = [NSFileManager defaultManager];
                                                             
                                                             NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
                                                             
                                                             [fileManager moveItemAtURL:temporaryFileLocation
                                                                                  toURL:localURL
                                                                                  error:&error];
                                                             
                                                             NSError *attachmentError = nil;
                                                             
                                                             if ([[urlString pathExtension] isEqualToString:@"webp"]) {
                                                                 UIImage *image = [UIImage imageWithWebPData:[NSData dataWithContentsOfURL:localURL]];
                                                                 NSData *imageData = UIImagePNGRepresentation(image);
                                                                 [imageData writeToURL:localURL atomically:YES];
                                                             }
                                                             attachment = [UNNotificationAttachment attachmentWithIdentifier:[NSString stringWithFormat:@"%ld",(unsigned long)idx] URL:localURL options:nil error:&attachmentError];
                                                             
                                                             if (attachmentError) {
                                                                 NSLog(@"%@", attachmentError);
                                                             }
                                                         }
                                                         
                                                         NSLog(@"Sending Callback");
                                                         completionHandler(attachment, idx);
                                                     }];
    
    [task resume];
}

#endif

@end

