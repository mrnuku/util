//
//  UIImage+RenderStuff.h
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 28/05/15.
//  Copyright (c) 2015 Incepteam. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* kRenderStuffBackground;
extern NSString* kRenderStuffSize;
extern NSString* kRenderStuffColor;

extern NSString* kRenderStuffObject;
extern NSString* kRenderStuffPosition;

@interface RenderStuffCustomShape : NSObject

@property (nonatomic, strong) UIColor *fillColor;

@end

@interface RenderStuffCircle : RenderStuffCustomShape

@property (nonatomic, assign) CGFloat radius;

+ (RenderStuffCircle *)makeCircleWithColor:(UIColor *)color andRadius:(CGFloat)radius;

@end

@interface UIImage (RenderStuff)

+ (UIImage *)renderImageUsingDictionary:(NSDictionary *)dict;
+ (NSDictionary *)makeRenderBackgroundWithColor:(UIColor *)color andSize:(CGSize)size;
+ (NSDictionary *)makeRenderObject:(id)object withCenterPosition:(CGPoint)position;

- (UIImage *)tintedCopyWithTintColor:(UIColor *)color;

@end
