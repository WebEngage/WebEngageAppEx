//
//  UIColor+DarkMode.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+DarkMode.h"

@implementation UIColor (DarkMode)

+ (UIColor *)WEXWhiteColor {
    if (@available(iOS 13.0, *)) {
        return UIColor.systemBackgroundColor;
    } else {
        return UIColor.whiteColor;
    }
}

+ (UIColor *)WEXGreyColor {
    if (@available(iOS 13.0, *)) {
        return UIColor.systemGrayColor;
    } else {
        return UIColor.lightGrayColor;
    }
}

+ (UIColor *)WEXLabelColor {
    if (@available(iOS 13.0, *)) {
        return UIColor.labelColor;
    } else {
        return UIColor.blackColor;
    }
}

+ (UIColor *)WEXLightTextColor {
    if (@available(iOS 13.0, *)) {
        return UIColor.systemGray4Color;
    } else {
        return UIColor.lightTextColor;
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString defaultColor:(UIColor *)defaultColor {
    if (hexString == (id)[NSNull null] || hexString.length == 0) {
        return defaultColor;
    }
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    
    if ([hexString hasPrefix:@"#"]) {
        [scanner setScanLocation:1]; // bypass '#' character
    } else {
        [scanner setScanLocation:0];
    }
    
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
