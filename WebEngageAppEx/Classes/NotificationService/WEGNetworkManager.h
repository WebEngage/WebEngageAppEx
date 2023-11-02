//
//  WEGNetworkManager.h
//  WebEngageBannerPush
//
//  Created by Uday Sharma on 30/10/23.
//

#import <Foundation/Foundation.h>

@interface WEGNetworkManager : NSObject

+ (instancetype)sharedManager;
- (NSURLRequest *)getModifiedUrl:(NSURLRequest *)request;
- (NSURLRequest *)getModifiedCommonRequest:(NSURLRequest *)request;
- (NSUserDefaults *)getSharedUserDefaults;

@end
