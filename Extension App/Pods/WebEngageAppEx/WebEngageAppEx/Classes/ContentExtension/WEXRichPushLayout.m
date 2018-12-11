//
//  WEXRichPushLayout.m
//  WebEngage
//
//  Created by Arpit on 13/04/17.
//  Copyright © 2017 Saumitra R. Bhave. All rights reserved.
//

#import "WEXRichPushLayout.h"


@interface WEXRichPushLayout ()
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property(nonatomic, strong, readwrite) WEXRichPushNotificationViewController* viewController;
@property(nonatomic, strong, readwrite) UIView* view;
#endif
@end


@implementation WEXRichPushLayout

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
-(instancetype) initWithNotificationViewController: (WEXRichPushNotificationViewController*) viewController {
    
    if (self = [super init]) {
        self.viewController = viewController;
        self.view = viewController.view;
    }
    
    return self;
}

-(void)didReceiveNotification:(UNNotification *)notification {}
#endif

@end
