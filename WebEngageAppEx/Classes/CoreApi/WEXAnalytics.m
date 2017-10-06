//
//  AEEventManager.m
//  appEngageSdk
//
//  Created by Saumitra R. Bhave on 16/06/15.
//  Copyright (c) 2015 Saumitra R. Bhave. All rights reserved.
//

#import "WEXAnalytics.h"

@interface WEXAnalytics ()

@property (strong,nonatomic,readwrite) NSUserDefaults* appGroupDefaults;
+(void) trackInternalEventWithName:(NSString*)eventName andValue:(NSDictionary*)eventValue asSystemEvent:(BOOL)val;
@end

@implementation WEXAnalytics

+(void) trackInternalEventWithName:(NSString*)eventName andValue:(NSDictionary*)eventValue asSystemEvent:(BOOL)val {
    NSString* eventKey = [@"weg_event_" stringByAppendingString:[[NSUUID alloc] init].UUIDString];
    [[WEXCoreUtils getDefaults] setObject:@{@"event_name":eventName,@"event_value":eventValue, @"is_system":[NSNumber numberWithBool:val]} forKey:eventKey];
    [[WEXCoreUtils getDefaults] synchronize];
}

+(void) trackEventWithName:(NSString*)eventName andValue:(NSDictionary*)eventValue{
    if ([eventName hasPrefix:@"we_"]) {
        [self trackInternalEventWithName:[eventName substringFromIndex:3] andValue:eventValue asSystemEvent:YES];
    }else{
        [self trackInternalEventWithName:eventName andValue:@{@"event_data_overrides" : eventValue} asSystemEvent:NO];
    }
}

+(void) trackEventWithName:(NSString*)eventName{
    [self trackEventWithName:eventName andValue:@{}];
}
@end
