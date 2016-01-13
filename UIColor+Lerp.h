//
//  UIColor+Lerp.h
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 04/12/15.
//  Copyright © 2015 Incepteam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Lerp)

- (instancetype)lerpColorToColor:(UIColor *)color withFraction:(CGFloat)fraction;

@end
