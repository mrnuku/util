//
//  UIColor+Lerp.m
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 04/12/15.
//  Copyright © 2015 Incepteam. All rights reserved.
//

#import "UIColor+Lerp.h"

@implementation UIColor (Lerp)

- (instancetype)lerpColorToColor:(UIColor *)color withFraction:(CGFloat)fraction {
    CGFloat components1[4], components2[4], components3[4];
    
    if (fraction <= 0.0) {
        return self;
    }
    else if (fraction >= 1.0) {
        return color;
    }
    
    [self getRed:&components1[0] green:&components1[1] blue:&components1[2] alpha:&components1[3]];
    [color getRed:&components2[0] green:&components2[1] blue:&components2[2] alpha:&components2[3]];
    
    memcpy(components3, components1, sizeof(components1));
    components3[0] += (components2[0] - components1[0]) * fraction;
    components3[1] += (components2[1] - components1[1]) * fraction;
    components3[2] += (components2[2] - components1[2]) * fraction;
    components3[3] += (components2[3] - components1[3]) * fraction;
    
    return [UIColor colorWithRed:components3[0] green:components3[1] blue:components3[2] alpha:components3[3]];
}

@end
