//
//  WENetworkResponse.h
//  Pods
//
//  Created by Shubham Naidu on 26/06/24.
//

#import <Foundation/Foundation.h>

@interface WENetworkResponse : NSObject

@property (nonatomic, strong, nullable) NSData *data;
@property (nonatomic, strong, nullable) NSURLResponse *response;
@property (nonatomic, strong, nullable) NSError *error;

//- ( _Nullable )init NS_UNAVAILABLE;
- (instancetype _Nullable )initWithData:(NSData * _Nullable)data response:(NSURLResponse * _Nullable)response error:(NSError * _Nullable)error NS_DESIGNATED_INITIALIZER;

+ (instancetype _Nullable )createWithData:(NSData * _Nullable)data response:(NSURLResponse * _Nullable)response error:(NSError * _Nullable)error;

@end
