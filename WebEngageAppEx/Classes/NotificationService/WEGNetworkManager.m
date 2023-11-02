//
//  WEGNetworkManager.m
//  WebEngageBannerPush
//
//  Created by Uday Sharma on 30/10/23.
//

#import "WEGNetworkManager.h"

@implementation WEGNetworkManager

+ (instancetype)sharedManager {
    static WEGNetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (NSURLRequest *)getModifiedUrl:(NSURLRequest *)request{
    NSString *regexPattern = @"https://[^/]*\\.webengage\\.";
    
    // Different regex, so have to check it individually
    NSArray<NSURL *> *uniqueRegexUrls = @[[NSURL URLWithString:@"https://s3.amazonaws.com/webengage-zfiles-gc/"]];
    
    // Check if each base URL contains ".webengage" or ".webengage-zfiles-gc" using the regular expression
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern options:0 error:&error];
    
    if (error) {
        // Handle the error here
        return nil;
    }
    
    for (NSURL *uniqueUrl in uniqueRegexUrls) {
        if ([regex firstMatchInString:request.URL.absoluteString options:0 range:NSMakeRange(0, request.URL.absoluteString.length)]) {
            return [self getModifiedCommonRequest:request];
        }
        else if ([request.URL isEqual:uniqueUrl]) {
            return [self getModifiedCommonRequest:request];
        }
        else {
            return request;
        }
    }
    
    return request;
}

- (NSURLRequest *)getModifiedCommonRequest:(NSURLRequest *)request{
  
    NSMutableURLRequest *urlRequest = [request mutableCopy];
    NSUserDefaults *defaults = [self getSharedUserDefaults];
    NSString *cuid = [defaults objectForKey:@"cuid"];
    NSString *license_code = [defaults objectForKey:@"license_code"];
    
    if (cuid) {
        [urlRequest addValue:cuid forHTTPHeaderField:@"cuid"];
        NSString *jwtToken = [defaults objectForKey:@"jwtToken"];
        [urlRequest addValue:[NSString stringWithFormat:@"Bearer %@", jwtToken ?: @""] forHTTPHeaderField:@"Authorization"];
    }
    
    [urlRequest addValue:license_code forHTTPHeaderField:@"lc"];
    return [urlRequest copy];
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

@end
