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
- (void)onResponse:(WENetworkResponse * _Nonnull)response completionHandler:(void (^ _Nonnull)(WENetworkResponse * _Nonnull))completionHandler;

- (void)onRequest:(NSURLRequest * _Nonnull)request completionHandler:(void (^ _Nonnull)(NSURLRequest * _Nonnull))completionHandler;

@end
