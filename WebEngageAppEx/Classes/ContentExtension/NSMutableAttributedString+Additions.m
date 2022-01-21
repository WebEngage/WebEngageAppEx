//
//  NSMutableAttributedString+Additions.m
//  WebEngage
//
//  Copyright (c) 2017 Webklipper Technologies Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableAttributedString+Additions.h"

@implementation NSMutableAttributedString (Additions)

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

@end
