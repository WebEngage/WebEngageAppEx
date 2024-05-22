//
//  WEXRichPushNotificationViewController.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//


#import "WEXRichPushNotificationViewController+Private.h"
#import "WEXCarouselPushNotificationViewController.h"
#import "WEXRatingPushNotificationViewController.h"
#import "WEXBannerPushNotificationViewController.h"
#import "WEXTextPushNotificationViewController.h"
#import "WEXRichPushLayout.h"
#import <WebEngageAppEx/WEXAnalytics.h>
#import <WebEngageAppEx/WEXRichPushNotificationViewController.h>
#import "NSMutableAttributedString+Additions.h"
#import <WebEngageAppEx-Swift.h>

#define WEX_CONTENT_EXTENSION_VERSION @"1.1.3"

API_AVAILABLE(ios(10.0))
@interface WEXRichPushNotificationViewController ()

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

@property (nonatomic) UILabel *label;
@property (nonatomic) WEXRichPushLayout *currentLayout;
@property (nonatomic) UNNotification *notification;
@property (nonatomic) NSUserDefaults *richPushDefaults;

@property (atomic) BOOL isRendering;
@property (atomic) BOOL isDarkMode;

#endif

@end


@implementation WEXRichPushNotificationViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000

- (void)loadView {
    self.view = [[UIView alloc] init];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (self.label) {
        [self.label removeFromSuperview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self updateActivityWithObject:[NSNumber numberWithBool:YES] forKey:@"collapsed"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.label removeFromSuperview];
        self.currentLayout = nil;
        self.notification = nil;
    });
}

- (BOOL)canBecomeFirstResponder {
    
    if (self.currentLayout && [self.currentLayout respondsToSelector:@selector(canBecomeFirstResponder)]) {
        return (BOOL)[self.currentLayout performSelector:@selector(canBecomeFirstResponder)];
    }
    return NO;
}

- (UIView *)inputAccessoryView {
    
    if (self.currentLayout && [self.currentLayout respondsToSelector:@selector(inputAccessoryView)]) {
        return [self.currentLayout performSelector:@selector(inputAccessoryView)];
    } else {
        
        return [super inputAccessoryView];
    }
}

- (UIView *)inputView {
    
    if (self.currentLayout && [self.currentLayout respondsToSelector:@selector(inputView)]) {
        return [self.currentLayout performSelector:@selector(inputView)];
    } else {
        return [super inputView];
    }
}

- (void)didReceiveNotification:(UNNotification *)notification  API_AVAILABLE(ios(10.0)) {
    
    if([notification.request.content.userInfo[@"source"] isEqualToString:@"webengage"]) {
        self.notification = notification;
        self.isRendering = YES;
        [self updateDarkModeStatus];
        [self setExtensionDefaults];
        NSString *appGroup = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEX_APP_GROUP"];
        
        if (!appGroup) {
            
            /*
             Retrieving the app bundle identifier using the method described here:
             https://stackoverflow.com/a/27849695/1357328
             */
            
            NSBundle *bundle = [NSBundle mainBundle];
            
            if ([[bundle.bundleURL pathExtension] isEqualToString:@"appex"]) {
                // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
                bundle = [NSBundle bundleWithURL:[[bundle.bundleURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent]];
            }
            
            NSString *bundleIdentifier = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
            
            appGroup = [NSString stringWithFormat:@"group.%@.WEGNotificationGroup", bundleIdentifier];
        }
        
        self.richPushDefaults = [[NSUserDefaults alloc] initWithSuiteName:appGroup];
        
        [self updateActivityWithObject:[NSNumber numberWithBool:NO] forKey:@"collapsed"];
        [self updateActivityWithObject:[NSNumber numberWithBool:YES] forKey:@"expanded"];
        
        NSString *style = self.notification.request.content.userInfo[@"expandableDetails"][@"style"];
        self.currentLayout = [self layoutForStyle:style];
        
        if (self.currentLayout) {
            [self.currentLayout didReceiveNotification:notification];
        }
    }
}

- (void)setExtensionDefaults {
    NSUserDefaults *sharedDefaults = [self getSharedUserDefaults];
    // Write operation only if key is not present in the UserDefaults
        [sharedDefaults setValue:WEX_CONTENT_EXTENSION_VERSION forKey:@"WEG_Content_Extension_Version"];
        [sharedDefaults synchronize];
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

- (WEXRichPushLayout *)layoutForStyle:(NSString *)style {
    
    if (style && [style isEqualToString:@"CAROUSEL_V1"]) {
        return [[WEXCarouselPushNotificationViewController alloc] initWithNotificationViewController:self];
    } else if (style && [style isEqualToString:@"RATING_V1"]) {
        return [[WEXRatingPushNotificationViewController alloc] initWithNotificationViewController:self];
    } else if (style && [style isEqualToString:@"BIG_PICTURE"]) {
        return [[WEXBannerPushNotificationViewController alloc] initWithNotificationViewController:self];
    } else if (style && [style isEqualToString:@"BIG_TEXT"]) {
        return [[WEXTextPushNotificationViewController alloc] initWithNotificationViewController:self];
    } else if (style && [style isEqualToString:@"OVERLAY"]) {
       return [[WEXOverlayPushNotificationViewController alloc] initWithNotificationViewController:self];
   }
    
    return nil;
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion  API_AVAILABLE(ios(10.0)) {
    if([response.notification.request.content.userInfo[@"source"] isEqualToString:@"webengage"]) {
        [self.currentLayout didReceiveNotificationResponse:response completionHandler:completion];
    }
}

- (void)traitCollectionDidChange: (UITraitCollection *) previousTraitCollection {
    [super traitCollectionDidChange: previousTraitCollection];
    [self updateDarkModeStatus];
}

- (NSMutableDictionary *) getActivityDictionaryForCurrentNotification {
    
    NSString *expId = self.notification.request.content.userInfo[@"experiment_id"];
    NSString *notifId = self.notification.request.content.userInfo[@"notification_id"];
    NSString *finalNotifId = [[expId stringByAppendingString:@"|"] stringByAppendingString:notifId];
    NSString *expandableDetails = self.notification.request.content.userInfo[@"expandableDetails"];
    
    id customData = self.notification.request.content.userInfo[@"customData"];
    
    NSMutableDictionary *dictionary = [[self.richPushDefaults dictionaryForKey:finalNotifId] mutableCopy];
    
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:expId forKey:@"experiment_id"];
        [dictionary setObject:notifId forKey:@"notification_id"];
        [dictionary setObject:expandableDetails forKey:@"expandableDetails"];
        
        if (customData && [customData isKindOfClass:[NSArray class]]) {
            [dictionary setObject:customData forKey:@"customData"];
        }
    }
    
    return dictionary;
}

- (void)updateActivityWithObject:(id)object forKey:(NSString *)key {
    
    NSMutableDictionary *activityDictionary = [self getActivityDictionaryForCurrentNotification];
    
    [activityDictionary setObject:object forKey:key];
    
    [self setActivityForCurrentNotification:activityDictionary];
}

- (void)setActivityForCurrentNotification:(NSDictionary *)activity {
    
    NSString *expId = self.notification.request.content.userInfo[@"experiment_id"];
    NSString *notifId = self.notification.request.content.userInfo[@"notification_id"];
    
    NSString *finalNotifId = [[expId stringByAppendingString:@"|"] stringByAppendingString:notifId];
    
    [self.richPushDefaults setObject:activity forKey:finalNotifId];
    [self.richPushDefaults synchronize];
}

- (void)addSystemEventWithName:(NSString *)eventName
                    systemData:(NSDictionary *)systemData
               applicationData:(NSDictionary *)applicationData {
    
    [self addEventWithName:eventName
                systemData:systemData
           applicationData:applicationData
                  category:@"system"];
}

- (void)addEventWithName:(NSString *)eventName
              systemData:(NSDictionary *)systemData
         applicationData:(NSDictionary *)applicationData
                category:(NSString *)category {
    
    id customData = self.notification.request.content.userInfo[@"customData"];
    
    NSMutableDictionary *customDataDictionary = [[NSMutableDictionary alloc] init];
    
    if (customData && [customData isKindOfClass:[NSArray class]]) {
        NSArray *customDataArray = customData;
        for (NSDictionary *customDataItem in customDataArray) {
            customDataDictionary[customDataItem[@"key"]] = customDataItem[@"value"];
        }
    }
    
    if (applicationData) {
        [customDataDictionary addEntriesFromDictionary:applicationData];
    }
    
    if ([category isEqualToString:@"system"]) {
        [WEXAnalytics trackEventWithName:[@"we_" stringByAppendingString:eventName]
                                andValue:@{
            @"system_data_overrides": systemData ? systemData : @{},
            @"event_data_overrides": customDataDictionary
        }];
    } else {
        [WEXAnalytics trackEventWithName:eventName andValue:customDataDictionary];
    }
}

- (void)setCTAWithId:(NSString *)ctaId andLink:(NSString *)actionLink {
    
    NSDictionary *cta = @{@"id": ctaId, @"actionLink": actionLink};
    
    [self updateActivityWithObject:cta forKey:@"cta"];
}

- (NSTextAlignment)naturalTextAligmentForText:(NSString*)text {
    if (text == (id)[NSNull null] || text.length == 0 ) {
        return NSTextAlignmentLeft;
    }
    
    NSArray *tagschemes = [NSArray arrayWithObjects:NSLinguisticTagSchemeLanguage, nil];
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:tagschemes options:0];
    [tagger setString:text];
    NSString *language = [tagger tagAtIndex:0 scheme:NSLinguisticTagSchemeLanguage tokenRange:NULL sentenceRange:NULL];
    if (language && ([language rangeOfString:@"he"].location != NSNotFound || [language rangeOfString:@"ar"].location != NSNotFound)) {
        return NSTextAlignmentRight;
    } else {
        return NSTextAlignmentLeft;
    }
}

- (NSAttributedString *)getHtmlParsedString:(NSString *)textString isTitle:(BOOL)isTitle bckColor:(NSString *)bckColor {
    BOOL containsHTML = [self containsHTML:textString];
    NSString *inputString = textString;
    
    // Updating font attributes overrides Italic characteristic
    // Adding extra tags makes more sense
    if (containsHTML && isTitle) {
        inputString = [NSString stringWithFormat: @"<strong>%@</strong>", textString];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithData: [inputString dataUsingEncoding:NSUnicodeStringEncoding]
                                                   options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
                                                   documentAttributes: nil
                                                   error: nil
    ];
    
    if (!textString){ return  nil; }
    
    BOOL hasBckColor = bckColor && ![bckColor isEqualToString:@""];
    if (!hasBckColor && _isDarkMode) {
        [attributedString updateDefaultTextColor];
    }
    
    BOOL containsFontSize = [inputString rangeOfString:@"font-size"].location != NSNotFound;

    UIFont *defaultFont = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    /*
     If html string doesn't contain font-size,
     then setting default based on title position
     */
    
    if (containsHTML && containsFontSize == NO) {
        if (isTitle) {
            [attributedString setFontFaceWithFont:boldFont];
        } else {
            [attributedString setFontFaceWithFont:defaultFont];
        }
//        [attributedString trimWhiteSpace];
        
    } else if (containsHTML == NO) {
        if (isTitle) {
            [attributedString addAttribute:NSFontAttributeName value:boldFont range:NSMakeRange(0, attributedString.length)];
        } else {
            [attributedString addAttribute:NSFontAttributeName value:defaultFont range:NSMakeRange(0, attributedString.length)];
        }
        
    } else {
        [attributedString trimWhiteSpace];
    }
    
    return attributedString;
}

- (BOOL)containsHTML:(NSString *)value {
//    NSString *htmlRegex = @"<[a-z][\\s\\S]*>";
//    NSPredicate *htmlText = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", htmlRegex];
//    return [htmlText evaluateWithObject:value];
    return [value rangeOfString: @"<(\"[^\"]*\"|'[^']*'|[^'\">])*>" options:NSRegularExpressionSearch].location != NSNotFound;
}

- (void)updateDarkModeStatus {
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.isDarkMode = YES;
            return;
        }
    }
    self.isDarkMode = NO;
}

#endif

@end
