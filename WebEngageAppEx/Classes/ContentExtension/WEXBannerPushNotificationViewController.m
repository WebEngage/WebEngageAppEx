//
//  WEXBannerPushNotificationViewController.m
//  WebEngage
//
//  Copyright (c) 2022 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import "WEXBannerPushNotificationViewController.h"
#import "WEXRichPushNotificationViewController+Private.h"

#define CONTENT_PADDING  10
#define TITLE_BODY_SPACE 5
#define LANDSCAPE_ASPECT 0.5

API_AVAILABLE(ios(10.0))
@interface WEXBannerPushNotificationViewController ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

@property (nonatomic) UNNotification *notification;
@property (nonatomic) NSUserDefaults *richPushDefaults;
@property (nonatomic) UIView *labelsContainerView;

#endif

@end

@implementation WEXBannerPushNotificationViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion{
    completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
}

- (void)didReceiveNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)) {
    
    self.notification = notification;
    
//    NSDictionary *userInfo = notification.request.content.userInfo;
//    NSString *catName = [userInfo valueForKeyPath:@"expandableDetails.category"];
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    NSString *bannerCatName = @"WEG_BANNER_V1";
//    [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> *existingCategories) {
//        UNNotificationCategory * defaultCategory ;
//        NSMutableSet * existingMutablecat = [[NSMutableSet alloc] init];
//        for(UNNotificationCategory *dic in existingCategories){
//            if([dic.identifier  isEqual: catName]){
//               defaultCategory = dic;
//           }
//            if(![dic.identifier  isEqual: bannerCatName]){
//                [existingMutablecat addObject:dic];
//            }
//        }
//
//
//        NSMutableArray *actions = [NSMutableArray arrayWithCapacity:defaultCategory.actions.count];
//
//        for (UNNotificationAction *action in defaultCategory.actions) {
//            UNNotificationAction *actionObject = [UNNotificationAction actionWithIdentifier:action.identifier
//                                                                                      title:action.title
//                                                                                    options:action.options];
//            [actions addObject:actionObject];
//        }
//
//        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:bannerCatName
//                                                                                  actions:actions
//                                                                        intentIdentifiers:@[]
//                                                                                  options:UNNotificationCategoryOptionCustomDismissAction];
//
//
//        [existingMutablecat addObject:category];
//        [center setNotificationCategories:existingMutablecat];
////        use
//
//
//
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//////                    NSLog(@"parameter1: %d parameter2: %f", parameter1, parameter2);
////            [self drawBannerViewWith:expandableDetails[@"image"]];
////        });
//
//    }];
    [self initialiseViewHierarchy];
    

}

- (void)initialiseViewHierarchy {
    self.view.backgroundColor = [UIColor whiteColor];
    
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
                        UIImageView *imageView = [[UIImageView alloc] init];
                        imageView.image = image;
                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        [mainContentView addSubview:imageView];
                    }
                }
            } else {
                NSLog(@"Expected to be running iOS version 10 or above");
            }
        }
    }
    [self setupLabelsContainer];
}

- (void)setupLabelsContainer {
    UIView *superViewWrapper = self.view.subviews[0];
    
    UIView *richContentView = [[UIView alloc] init];
    richContentView.backgroundColor = [UIColor whiteColor];
    
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
    NSAttributedString *attributedTitle = [[NSMutableAttributedString alloc]
                                           initWithData: [title dataUsingEncoding:NSUnicodeStringEncoding]
                                           options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                           documentAttributes: nil
                                           error: nil
    ];
    richTitleLabel.textAlignment = [self.viewController naturalTextAligmentForText:richTitleLabel.text];
    richTitleLabel.attributedText = attributedTitle;
    richTitleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    UILabel *richSubLabel = [[UILabel alloc] init];
    NSAttributedString *attributedSubTitle = [[NSMutableAttributedString alloc]
                                              initWithData: [subtitle dataUsingEncoding:NSUnicodeStringEncoding]
                                              options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                              documentAttributes: nil
                                              error: nil
    ];
    richSubLabel.textAlignment = [self.viewController naturalTextAligmentForText:richSubLabel.text];
    richSubLabel.attributedText = attributedSubTitle;
    richSubLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    
    UILabel *richBodyLabel = [[UILabel alloc] init];
    NSAttributedString *attributedBody = [[NSMutableAttributedString alloc]
                                          initWithData: [message dataUsingEncoding:NSUnicodeStringEncoding]
                                          options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                          documentAttributes: nil
                                          error: nil
    ];
    richBodyLabel.textAlignment = [self.viewController naturalTextAligmentForText:richBodyLabel.text];
    richBodyLabel.numberOfLines = 0;
    richBodyLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    richBodyLabel.attributedText = attributedBody;
    
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

