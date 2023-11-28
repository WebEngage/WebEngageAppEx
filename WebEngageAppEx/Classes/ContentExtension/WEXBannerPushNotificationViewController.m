//
//  WEXBannerPushNotificationViewController.m
//  WebEngage
//
//  Copyright (c) 2022 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import "WEXBannerPushNotificationViewController.h"
#import "WEXRichPushNotificationViewController+Private.h"
#import "UIColor+DarkMode.h"

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
                    UIImage *image = [UIImage imageWithData:imageData];
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
    [self setUpAppIconWithName];
}

- (void)setUpAppIconWithName {
    UIView *superViewWrapper = self.view.subviews[0];
    UIView *mainContentView = superViewWrapper.subviews[0];
    
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSString *primaryLanguage = preferredLanguages.firstObject;
    NSLocaleLanguageDirection languageDirection = [NSLocale characterDirectionForLanguage:primaryLanguage];


    // Create a superview for the app icon and app name
    UIView *appInfoContainer = [[UIView alloc] init];
    [mainContentView addSubview:appInfoContainer];

    // Assuming you have access to the app icon and app name
    UIImage *appIcon = [self appIcon];

    UIImageView *appIconImageView = [[UIImageView alloc] initWithImage:appIcon];
    appIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [appInfoContainer addSubview:appIconImageView];

    UILabel *appNameLabel = [[UILabel alloc] init];
    NSString* appName = [self appName];
    appNameLabel.text = appName;
    appNameLabel.font = [UIFont boldSystemFontOfSize:15.0]; // Set your desired bold font size
    appNameLabel.textColor = [UIColor blackColor]; // Set your desired text color
    appNameLabel.textAlignment = NSTextAlignmentLeft;
    
    // Set up a shadow with a vibrant color
    appNameLabel.layer.shadowColor = [UIColor whiteColor].CGColor; // Shadow color
    appNameLabel.layer.shadowRadius = 5.0; // Spread of the shadow
    appNameLabel.layer.shadowOpacity = 1.0; // Opacity of the shadow
    appNameLabel.layer.shadowOffset = CGSizeZero; // Offset of the shadow

    // Set up the attributed text with increased thickness
    NSDictionary *attributes = @{
        NSStrokeWidthAttributeName: @-5.0, // Set your desired thickness value
        NSStrokeColorAttributeName: [UIColor blackColor] // Set your desired text color
    };
    appNameLabel.attributedText = [[NSAttributedString alloc] initWithString:appName attributes:attributes];

    [appInfoContainer addSubview:appNameLabel];


    // Set up constraints for app icon and app name within the appInfoContainer
    appIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    appNameLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [appIconImageView.leadingAnchor constraintEqualToAnchor:appInfoContainer.leadingAnchor].active = YES;
    [appIconImageView.centerYAnchor constraintEqualToAnchor:appInfoContainer.centerYAnchor].active = YES;
    [appIconImageView.widthAnchor constraintEqualToConstant:20.0].active = YES; // Set your desired width
    [appIconImageView.heightAnchor constraintEqualToConstant:20.0].active = YES; // Set your desired height

    [appNameLabel.leadingAnchor constraintEqualToAnchor:appIconImageView.trailingAnchor constant:10.0].active = YES;
    [appNameLabel.centerYAnchor constraintEqualToAnchor:appIconImageView.centerYAnchor].active = YES;

    // Add the appInfoContainer to the mainContentView
    appInfoContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [appInfoContainer.leadingAnchor constraintEqualToAnchor:mainContentView.leadingAnchor constant:10.0].active = YES;
    [appInfoContainer.heightAnchor constraintEqualToConstant:20.0].active = YES; // Set your desired height
    [appInfoContainer.topAnchor constraintEqualToAnchor:mainContentView.topAnchor constant:10].active = YES;

    [self setupLabelsContainer];
}



- (UIImage *) appIcon {
    NSUserDefaults *sharedDefaults = [self getSharedUserDefaults];
    // Retrieve NSData from UserDefaults
       NSData *appIconData = [sharedDefaults objectForKey:@"app_icon"];
       
       // Convert NSData back to UIImage
       if (appIconData) {
           UIImage *appIcon = [UIImage imageWithData:appIconData];
           return appIcon;
       } else {
           return nil; // Handle the case where the image data is not available
       }
}

- (NSString *) appName {
    NSUserDefaults *sharedDefaults = [self getSharedUserDefaults];
    return [sharedDefaults objectForKey:@"app_name"];
}


- (void)setupLabelsContainer {
    UIView *superViewWrapper = self.view.subviews[0];
    NSString *colorHex = self.notification.request.content.userInfo[@"expandableDetails"][@"bckColor"];
    
    UIView *richContentView = [[UIView alloc] init];
//    richContentView.backgroundColor = [UIColor colorFromHexString:colorHex defaultColor:UIColor.WEXWhiteColor];
    
    richContentView.backgroundColor = UIColor.clearColor;
    
    
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSString *primaryLanguage = preferredLanguages.firstObject;
    NSLocaleLanguageDirection languageDirection = [NSLocale characterDirectionForLanguage:primaryLanguage];
  
    
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
    richTitleLabel.textColor = UIColor.whiteColor;
    richTitleLabel.textAlignment = [self.viewController naturalTextAligmentForText:richTitleLabel.text];
    
    UILabel *richSubLabel = [[UILabel alloc] init];
    richSubLabel.attributedText = [self.viewController getHtmlParsedString:subtitle isTitle:YES bckColor:colorHex];
    richSubLabel.textAlignment = [self.viewController naturalTextAligmentForText:richSubLabel.text];
    
    UILabel *richBodyLabel = [[UILabel alloc] init];
    richBodyLabel.attributedText = [self.viewController getHtmlParsedString:message isTitle:NO bckColor:colorHex];
    richBodyLabel.textAlignment = [self.viewController naturalTextAligmentForText:richBodyLabel.text];
    richBodyLabel.numberOfLines = 0;
    richBodyLabel.textColor = UIColor.whiteColor;
//    
//    if (languageDirection == NSLocaleLanguageDirectionRightToLeft) {
//        richBodyLabel.textAlignment = NSTextAlignmentRight;
//        richSubLabel.textAlignment = NSTextAlignmentRight;
//        richBodyLabel.textAlignment = NSTextAlignmentRight;
//    } else {
//        richBodyLabel.textAlignment = NSTextAlignmentLeft;
//        richSubLabel.textAlignment = NSTextAlignmentLeft;
//        richBodyLabel.textAlignment = NSTextAlignmentLeft;
//    }
//    
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
    UIView *appIconView = mainContentView.subviews[1];
    
    
    if (@available(iOS 10.0, *)) {
        superViewWrapper.translatesAutoresizingMaskIntoConstraints = NO;
        [superViewWrapper.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [superViewWrapper.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [superViewWrapper.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [appIconView.bottomAnchor constraintEqualToAnchor:richContentView.topAnchor].active = YES;
        
        //Top level view constraints
        mainContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [mainContentView.leadingAnchor constraintEqualToAnchor:mainContentView.superview.leadingAnchor].active = YES;
        [mainContentView.trailingAnchor constraintEqualToAnchor:mainContentView.superview.trailingAnchor].active = YES;
        [mainContentView.topAnchor constraintEqualToAnchor:mainContentView.superview.topAnchor].active = YES;
        
        richContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [richContentView.leadingAnchor constraintEqualToAnchor:richContentView.superview.leadingAnchor].active = YES;
        [richContentView.trailingAnchor constraintEqualToAnchor:richContentView.superview.trailingAnchor].active = YES;
        [richContentView.topAnchor constraintEqualToAnchor:appIconView.bottomAnchor].active = YES;
        
        [self.viewController.bottomLayoutGuide.topAnchor constraintEqualToAnchor:superViewWrapper.bottomAnchor].active = YES;
        
        //Main Content View ImageView constraints
        UIImageView *imageView = mainContentView.subviews[0];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImage *bannerImage = imageView.image;
        CGFloat imageAspect = LANDSCAPE_ASPECT;
        if (bannerImage && bannerImage.size.height != 0) {
            imageAspect = bannerImage.size.height/bannerImage.size.width;
        } else {
            imageAspect = 0;
        }
        
        [imageView.topAnchor constraintEqualToAnchor:superViewWrapper.topAnchor].active = YES;
        [imageView.leadingAnchor constraintEqualToAnchor:superViewWrapper.leadingAnchor].active = YES;
        [imageView.trailingAnchor constraintEqualToAnchor:superViewWrapper.trailingAnchor].active = YES;
        [imageView.heightAnchor constraintEqualToAnchor:imageView.widthAnchor multiplier:imageAspect].active = YES;
        [superViewWrapper.bottomAnchor constraintEqualToAnchor:imageView.bottomAnchor].active = YES;
        
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

