//
//  WEXAnalytics.h
//
//  Created by Saumitra R. Bhave on 16/06/15.
//  Copyright (c) 2015 Webklipper Technologies Pvt Ltd.. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WEXCoreUtils.h"

@interface WEXAnalytics : NSObject
+(void) trackEventWithName:(NSString*)eventName andValue:(NSDictionary*)eventValue;
+(void) trackEventWithName:(NSString*)eventName;
@end
