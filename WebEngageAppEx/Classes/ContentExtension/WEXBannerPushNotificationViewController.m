//
//  WEXBannerPushNotificationViewController.m
//  WebEngage
//
//  Copyright (c) 2022 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import "WEXBannerPushNotificationViewController.h"
#import "WEXRichPushNotificationViewController+Private.h"
#import "UIColor+DarkMode.h"
#import "UIImage+animatedGIF.h"

#define CONTENT_PADDING  10
#define TITLE_BODY_SPACE 5
#define LANDSCAPE_ASPECT 0.5

API_AVAILABLE(ios(10.0))
@interface WEXBannerPushNotificationViewController ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

@property (nonatomic) UNNotification *notification;

#endif

@end

@implementation WEXBannerPushNotificationViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (void)didReceiveNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)) {
    if([notification.request.content.userInfo[@"source"] isEqualToString:@"webengage"]) {
        self.notification = notification;
        [self initialiseViewHierarchy];
    }
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion{
    if([response.notification.request.content.userInfo[@"source"] isEqualToString:@"webengage"]) {
        completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
    }
}

- (void)initialiseViewHierarchy {
    self.view.backgroundColor = [UIColor WEXWhiteColor];
    
    UIView *superViewWrapper = [[UIView alloc] init];
    [self.view addSubview:superViewWrapper];
    
    UIView *mainContentView = [[UIView alloc] init];
    [superViewWrapper addSubview:mainContentView];
    
    [self setupBannerImageView];
}

- (void)setupBannerImageView {
    UIView *superViewWrapper = self.view.subviews[0];
    UIView *mainContentView = superViewWrapper.subviews[0];
    
    NSDictionary *expandableDetails = self.notification.request.content.userInfo[@"expandableDetails"];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    if (expandableDetails[@"image"]) {
        if (self.notification.request.content.attachments
            && self.notification.request.content.attachments.count > 0) {
            
            if (@available(iOS 10.0, *)) {
                UNNotificationAttachment *attachment = self.notification.request.content.attachments.firstObject;
                
                if ([attachment.URL startAccessingSecurityScopedResource]) {
                    NSData *imageData = [NSData dataWithContentsOfFile:attachment.URL.path];
                    UIImage *image = [UIImage animatedImageWithAnimatedGIFData:imageData];
                    [attachment.URL stopAccessingSecurityScopedResource];
                    if (image) {
                        imageView.image = image;
                    } else {
                        NSLog(@"Image not present in cache!");
                    }
                }
            } else {
                NSLog(@"Expected to be running iOS version 10 or above");
            }
        } else {
            NSLog(@"Attachment not present for: %@", expandableDetails[@"image"]);
        }
    } else {
        NSLog(@"Image not present in payload: %@", expandableDetails[@"image"]);
    }
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [mainContentView addSubview:imageView];
    [self setupLabelsContainer];
}

- (void)setupLabelsContainer {
    UIView *superViewWrapper = self.view.subviews[0];
    NSString *colorHex = self.notification.request.content.userInfo[@"expandableDetails"][@"bckColor"];
    
    UIView *richContentView = [[UIView alloc] init];
    richContentView.backgroundColor = [UIColor colorFromHexString:colorHex defaultColor:UIColor.WEXWhiteColor];
    
    NSDictionary *expandedDetails = self.notification.request.content.userInfo[@"expandableDetails"];
    NSString *title = expandedDetails[@"rt"];
    NSString *subtitle = expandedDetails[@"rst"];
    NSString *message = expandedDetails[@"rm"];
    
    BOOL titlePresent = title && ![title isEqualToString:@""];
    BOOL subTitlePresent = subtitle && ![subtitle isEqualToString:@""];
    BOOL messagePresent = message && ![message isEqualToString:@""];
    
    if (!titlePresent) {
        title = self.notification.request.content.title;
    }
    if (!subTitlePresent) {
        subtitle = self.notification.request.content.subtitle;
    }
    if (!messagePresent) {
        message = self.notification.request.content.body;
    }
    
    UILabel *richTitleLabel = [[UILabel alloc] init];
    richTitleLabel.attributedText = [self.viewController getHtmlParsedString:title isTitle:YES bckColor:colorHex];
    richTitleLabel.textAlignment = [self.viewController naturalTextAlignmentForText:richTitleLabel.text];
    
    UILabel *richSubLabel = [[UILabel alloc] init];
    richSubLabel.attributedText = [self.viewController getHtmlParsedString:subtitle isTitle:YES bckColor:colorHex];
    richSubLabel.textAlignment = [self.viewController naturalTextAlignmentForText:richSubLabel.text];
    
    UILabel *richBodyLabel = [[UILabel alloc] init];
    richBodyLabel.attributedText = [self.viewController getAttributedStringWithMessage:message colorHex:colorHex];
    richBodyLabel.numberOfLines = 0;
    
    [richContentView addSubview:richTitleLabel];
    [richContentView addSubview:richSubLabel];
    [richContentView addSubview:richBodyLabel];
    
    [superViewWrapper addSubview:richContentView];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    UIView *superViewWrapper = self.view.subviews[0];
    UIView *mainContentView = superViewWrapper.subviews[0];
    UIView *richContentView = superViewWrapper.subviews[1];
    
    if (@available(iOS 10.0, *)) {
        superViewWrapper.translatesAutoresizingMaskIntoConstraints = NO;
        [superViewWrapper.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [superViewWrapper.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [superViewWrapper.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [superViewWrapper.bottomAnchor constraintEqualToAnchor:richContentView.bottomAnchor].active = YES;
        
        //Top level view constraints
        mainContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [mainContentView.leadingAnchor constraintEqualToAnchor:mainContentView.superview.leadingAnchor].active = YES;
        [mainContentView.trailingAnchor constraintEqualToAnchor:mainContentView.superview.trailingAnchor].active = YES;
        [mainContentView.topAnchor constraintEqualToAnchor:mainContentView.superview.topAnchor].active = YES;
        
        richContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [richContentView.leadingAnchor constraintEqualToAnchor:richContentView.superview.leadingAnchor].active = YES;
        [richContentView.trailingAnchor constraintEqualToAnchor:richContentView.superview.trailingAnchor].active = YES;
        [richContentView.topAnchor constraintEqualToAnchor:mainContentView.bottomAnchor].active = YES;
        
        [self.viewController.bottomLayoutGuide.topAnchor constraintEqualToAnchor:superViewWrapper.bottomAnchor].active = YES;
        
        //Main Content View ImageView constraints
        UIImageView *imageView = mainContentView.subviews[0];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImage *bannerImage = imageView.image;
        CGFloat imageAspect = LANDSCAPE_ASPECT;
        if (bannerImage && bannerImage.size.height != 0) {
            imageAspect = bannerImage.size.height/bannerImage.size.width;
            if(imageAspect > 1){
                imageAspect = 1;
            }

        } else {
            imageAspect = 0;
        }
        
        [imageView.topAnchor constraintEqualToAnchor:mainContentView.topAnchor].active = YES;
        [imageView.leadingAnchor constraintEqualToAnchor:mainContentView.leadingAnchor].active = YES;
        [imageView.trailingAnchor constraintEqualToAnchor:mainContentView.trailingAnchor].active = YES;
        [imageView.heightAnchor constraintEqualToAnchor:imageView.widthAnchor multiplier:imageAspect].active = YES;
        [mainContentView.bottomAnchor constraintEqualToAnchor:imageView.bottomAnchor].active = YES;
        
        //Rich View labels
        UIView *richTitleLabel = richContentView.subviews[0];
        UIView *richSubTitleLabel = richContentView.subviews[1];
        UIView *richBodyLabel = richContentView.subviews[2];
        
        richTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [richTitleLabel.leadingAnchor
         constraintEqualToAnchor:richContentView.leadingAnchor
         constant:CONTENT_PADDING]
            .active = YES;
        [richTitleLabel.trailingAnchor
         constraintEqualToAnchor:richContentView.trailingAnchor
         constant:0 - CONTENT_PADDING]
            .active = YES;
        [richTitleLabel.topAnchor
         constraintEqualToAnchor:richContentView.topAnchor
         constant:CONTENT_PADDING]
            .active = YES;
        
        richSubTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [richSubTitleLabel.leadingAnchor
         constraintEqualToAnchor:richContentView.leadingAnchor
         constant:CONTENT_PADDING]
            .active = YES;
        [richSubTitleLabel.trailingAnchor
         constraintEqualToAnchor:richContentView.trailingAnchor
         constant:0 - CONTENT_PADDING]
            .active = YES;
        [richSubTitleLabel.topAnchor
         constraintEqualToAnchor:richTitleLabel.bottomAnchor
         constant:0]
            .active = YES;
        
        richBodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [richBodyLabel.leadingAnchor
         constraintEqualToAnchor:richContentView.leadingAnchor
         constant:CONTENT_PADDING]
            .active = YES;
        [richBodyLabel.trailingAnchor
         constraintEqualToAnchor:richContentView.trailingAnchor
         constant:0 - CONTENT_PADDING]
            .active = YES;
        [richBodyLabel.topAnchor constraintEqualToAnchor:richSubTitleLabel.bottomAnchor
                                                constant:0]
            .active = YES;
        [richBodyLabel.bottomAnchor
         constraintEqualToAnchor:richContentView.bottomAnchor
         constant:-CONTENT_PADDING]
            .active = YES;
    } else {
        NSLog(@"Expected to be running iOS version 10 or above");
    }
}

#endif

@end

