//
//  CALayer+UIColor.m
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 26/05/15.
//  Copyright (c) 2015 Incepteam. All rights reserved.
//

#import "CALayer+UIColor.h"

@implementation CALayer (UIColor)

- (void)setBorderUIColor:(UIColor *)color {
    self.borderColor = color.CGColor;
}

- (UIColor *)borderUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

- (void)setShadowUIColor:(UIColor *)color {
    self.shadowColor = color.CGColor;
}

- (UIColor *)shadowUIColor {
    return [UIColor colorWithCGColor:self.shadowColor];
}

@end
