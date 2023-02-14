//
//  WEXTextPushNotificationViewController.m
//  WebEngage
//
//  Copyright (c) 2022 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import "WEXTextPushNotificationViewController.h"
#import "WEXRichPushNotificationViewController+Private.h"
#import "UIColor+DarkMode.h"

#define CONTENT_PADDING  10
#define TITLE_BODY_SPACE 5
#define LANDSCAPE_ASPECT 0.5

API_AVAILABLE(ios(10.0))
@interface WEXTextPushNotificationViewController ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

@property (nonatomic) UNNotification *notification;

#endif

@end

@implementation WEXTextPushNotificationViewController

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
    richTitleLabel.textAlignment = [self.viewController naturalTextAligmentForText:richTitleLabel.text];
    
    UILabel *richSubLabel = [[UILabel alloc] init];
    richSubLabel.attributedText = [self.viewController getHtmlParsedString:subtitle isTitle:YES bckColor:colorHex];
    richSubLabel.textAlignment = [self.viewController naturalTextAligmentForText:richSubLabel.text];
    
    UILabel *richBodyLabel = [[UILabel alloc] init];
    richBodyLabel.attributedText = [self.viewController getHtmlParsedString:message isTitle:NO bckColor:colorHex];
    richBodyLabel.textAlignment = [self.viewController naturalTextAligmentForText:richBodyLabel.text];
    richBodyLabel.numberOfLines = 0;
    
    [richContentView addSubview:richTitleLabel];
    [richContentView addSubview:richSubLabel];
    [richContentView addSubview:richBodyLabel];
    
    [superViewWrapper addSubview:richContentView];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    UIView *superViewWrapper = self.view.subviews[0];
    UIView *richContentView = superViewWrapper.subviews[0];
    
    if (@available(iOS 10.0, *)) {
        superViewWrapper.translatesAutoresizingMaskIntoConstraints = NO;
        [superViewWrapper.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [superViewWrapper.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [superViewWrapper.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        [superViewWrapper.bottomAnchor constraintEqualToAnchor:richContentView.bottomAnchor].active = YES;
        
        richContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [richContentView.leadingAnchor constraintEqualToAnchor:superViewWrapper.leadingAnchor].active = YES;
        [richContentView.trailingAnchor constraintEqualToAnchor:superViewWrapper.trailingAnchor].active = YES;
        [richContentView.topAnchor constraintEqualToAnchor:superViewWrapper.topAnchor].active = YES;
        
        [self.viewController.bottomLayoutGuide.topAnchor constraintEqualToAnchor:superViewWrapper.bottomAnchor].active = YES;
        
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

