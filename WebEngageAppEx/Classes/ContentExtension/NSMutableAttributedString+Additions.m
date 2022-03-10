//
//  NSMutableAttributedString+Additions.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableAttributedString+Additions.h"
#import "UIColor+DarkMode.h"

@implementation NSMutableAttributedString (Additions)

- (void)updateDefaultTextColor {
    if (@available(iOS 13.0, *)) {
        [self beginEditing];
        [self enumerateAttribute:NSForegroundColorAttributeName
                         inRange:NSMakeRange(0, self.length)
                         options:0
                      usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            
            UIColor *color = (UIColor *)value;
            UIColor *labelColor = [UIColor WEXLabelColor];
            NSString *colorHex = [self hexStringFromColor:color];
            
            if ([colorHex isEqualToString:@"000000"]) {
                [self removeAttribute:NSForegroundColorAttributeName range:range];
                [self addAttribute:NSForegroundColorAttributeName value:labelColor range:range];
            }
        }];
        [self endEditing];
    }
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

- (void)setFontFaceWithFont:(UIFont *)font {
    [self beginEditing];
    [self enumerateAttribute:NSFontAttributeName
                     inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        
        UIFont *oldFont = (UIFont *)value;
        UIFontDescriptor *newFontDescriptor = [[oldFont.fontDescriptor fontDescriptorWithFamily:font.familyName] fontDescriptorWithSymbolicTraits:oldFont.fontDescriptor.symbolicTraits];
        UIFont *newFont = [UIFont fontWithDescriptor:newFontDescriptor size:font.pointSize];
        
        if (newFont) {
            [self removeAttribute:NSFontAttributeName range:range];
            [self addAttribute:NSFontAttributeName value:newFont range:range];
        }
    }];
    [self endEditing];
}

- (void)trimWhiteSpace {
    NSCharacterSet *legalChars = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
    NSRange startRange = [self.string rangeOfCharacterFromSet: legalChars];
    NSRange endRange = [self.string rangeOfCharacterFromSet: legalChars options:NSBackwardsSearch];
    if (startRange.location == NSNotFound || endRange.location == NSNotFound) {
        // there are no legal characters in self --- it is ALL whitespace, and so we 'trim' everything leaving an empty string
        [self setAttributedString:[NSAttributedString new]];
    }
    else {
        NSUInteger startLocation = NSMaxRange(startRange), endLocation = endRange.location;
        NSRange range = NSMakeRange(startLocation - 1, endLocation - startLocation + 2);
        [self setAttributedString:[self attributedSubstringFromRange:range]];
    }
}

@end
