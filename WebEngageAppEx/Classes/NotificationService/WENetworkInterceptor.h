//
//  WENetworkInterceptor.h
//  WEGExtensionApp
//
//  Created by Shubham Naidu on 28/06/24.
//  Copyright © 2024 Yogesh Singh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WENetworkResponse.h"

@protocol WENetworkInterceptor <NSObject>

@optional
- (void)onRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *request))completionHandler;
- (void)onResponse:(WENetworkResponse *)response completionHandler:(void (^)(WENetworkResponse *response))completionHandler;

@end
