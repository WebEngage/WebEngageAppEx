//
//  UIColor+DarkMode.h
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DarkMode)

+ (UIColor *)WEXWhiteColor;

+ (UIColor *)WEXGreyColor;

+ (UIColor *)WEXLabelColor;

+ (UIColor *)WEXLightTextColor;

+ (UIColor *)colorFromHexString:(NSString *)hexString defaultColor:(UIColor *)defaultColor;

@end
