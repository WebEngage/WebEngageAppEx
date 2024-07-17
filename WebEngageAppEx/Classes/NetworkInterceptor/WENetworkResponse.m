//
//  WENetworkResponse.m
//  Pods
//
//  Created by Shubham Naidu on 26/06/24.
//

#import "WENetworkResponse.h"

@implementation WENetworkResponse : NSObject 

- (instancetype)initWithData:(NSData * _Nullable)data response:(NSURLResponse * _Nullable)response error:(NSError * _Nullable)error {
    self = [super init];
    if (self) {
        data = data;
        response = response;
        error = error;
    }
    return self;
}

+ (instancetype)createWithData:(NSData * _Nullable)data response:(NSURLResponse * _Nullable)response error:(NSError * _Nullable)error {
    return [[WENetworkResponse alloc] initWithData:data response:response error:error];
}

@end
