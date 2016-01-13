//
//  UIImage+RenderStuff.m
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 28/05/15.
//  Copyright (c) 2015 Incepteam. All rights reserved.
//

#import "UIImage+RenderStuff.h"

NSString* kRenderStuffBackground = @"backGround";
NSString* kRenderStuffSize = @"size";
NSString* kRenderStuffColor = @"color";

NSString* kRenderStuffObject = @"object";
NSString* kRenderStuffPosition = @"position";

@implementation RenderStuffCustomShape

@end

@implementation RenderStuffCircle

+ (RenderStuffCircle *)makeCircleWithColor:(UIColor *)color andRadius:(CGFloat)radius {
    RenderStuffCircle *circle = [RenderStuffCircle new];
    
    circle.fillColor = color;
    circle.radius = radius;
    
    return circle;
}

@end

@implementation UIImage (RenderStuff)

#if 0
- (CGImageRef)createGaugeMaskFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue
{
    CGRect bounds = CGRectZero;
    CGRect circleRect = CGRectInset(bounds, 5, 5);
    CGFloat radius = MIN(CGRectGetMidX(circleRect), CGRectGetMaxY(circleRect));
    CGPoint center = CGPointMake(CGRectGetMidX(circleRect), CGRectGetMaxY(circleRect));
    CGFloat startAngle = fromValue / 100 * M_PI - M_PI;
    CGFloat endAngle = toValue / 100 * M_PI - M_PI;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect scaledRect = bounds;
    scaledRect.size.width *= scale;
    scaledRect.size.height *= scale;
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx = CGBitmapContextCreate(NULL, scaledRect.size.width, scaledRect.size.height, 8, 0, grayColorSpace, (CGBitmapInfo)kCGImageAlphaNone);
    UIGraphicsPushContext(ctx);
    //CGAffineTransform flipTransform = CGAffineTransformMake(scale, 0, 0, -scale, 0, self.bounds.size.height*scale);
    //CGContextConcatCTM(ctx, flipTransform);
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGContextConcatCTM(ctx, scaleTransform);
    
    //UIGraphicsPushContext(context);
    //CGContextSaveGState(context);
    
    CGContextAddRect(ctx, CGRectInfinite);
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddArc(ctx, center.x, center.y, radius / 2, 0, M_PI*2, 0);
    CGContextClosePath(ctx);
    CGPathRef copiedPath = CGContextCopyPath(ctx);
    UIBezierPath* insidePath = [UIBezierPath bezierPathWithCGPath:copiedPath];
    CGPathRelease(copiedPath);
    insidePath.usesEvenOddFillRule = YES;
    CGContextBeginPath(ctx);
    [insidePath addClip];
    [[UIColor whiteColor] setFill];
    
    CGContextMoveToPoint(ctx, center.x, center.y);
    CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    //UIBezierPath* animPath = [UIBezierPath bezierPathWithCGPath:CGContextCopyPath(ctx)];
    
    //CGContextRestoreGState(context);
    //UIGraphicsPopContext();
    
    CGImageRef fillImage = CGBitmapContextCreateImage(ctx);
    
    UIGraphicsPopContext();
    CGContextRelease(ctx);
    CGColorSpaceRelease(grayColorSpace);
    
    return fillImage;
}
#endif

+ (UIImage *)renderImageUsingDictionary:(NSDictionary *)dict {
    NSDictionary *backgroundDict = [dict objectForKey:kRenderStuffBackground];
    NSDictionary *backgroundSizeDict = [backgroundDict objectForKey:kRenderStuffSize];
    UIColor *backgroundColor = [backgroundDict objectForKey:kRenderStuffColor];
    
    if (!backgroundDict || !backgroundSizeDict || !backgroundColor) {
        return nil;
    }
    
    CGSize size;
    if (!CGSizeMakeWithDictionaryRepresentation((CFDictionaryRef)backgroundSizeDict, &size)) {
        return nil;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize scaledSize = size;
    scaledSize.width *= scale;
    scaledSize.height *= scale;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, scaledSize.width, scaledSize.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    UIGraphicsPushContext(ctx);
    CGAffineTransform flipTransform = CGAffineTransformMake(scale, 0, 0, -scale, 0, scaledSize.height);
    CGContextConcatCTM(ctx, flipTransform);
    
    CGContextSetFillColorWithColor(ctx, backgroundColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, scaledSize.width, scaledSize.height));
    
    for (NSString *objectKey in dict.keyEnumerator) {
        if ([objectKey isEqualToString:kRenderStuffBackground]) {
            continue;
        }
        
        NSDictionary *objectDict = [dict objectForKey:objectKey];
        id object = [objectDict objectForKey:kRenderStuffObject];
        NSDictionary *positionDict = [objectDict objectForKey:kRenderStuffPosition];
        
        CGPoint position;
        if (!CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)positionDict, &position)) {
            continue;
        }
        
        if ([object isKindOfClass:[UIImage class]]) {
            UIImage *objectImage = object;
            [objectImage drawAtPoint:position];
        }
        else if ([object isKindOfClass:[NSAttributedString class]]) {
            NSAttributedString *objectAttributedString = object;
            [objectAttributedString drawAtPoint:position];
        }
        else if ([object isKindOfClass:[RenderStuffCircle class]]) {
            RenderStuffCircle *objectCircle = object;
            CGFloat radius = objectCircle.radius;
            CGContextMoveToPoint(ctx, position.x, position.y);
            CGContextAddArc(ctx, position.x + radius, position.y + radius, radius, 0, M_PI * 2, 0);
            CGContextClosePath(ctx);
            CGContextSetFillColorWithColor(ctx, objectCircle.fillColor.CGColor);
            CGContextFillPath(ctx);
        }
    }
    
    CGImageRef resultImage = CGBitmapContextCreateImage(ctx);
    
    UIGraphicsPopContext();
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:resultImage scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(resultImage);
    
    return image;
}

+ (NSDictionary *)makeRenderBackgroundWithColor:(UIColor *)color andSize:(CGSize)size {
    return @{
        kRenderStuffColor: color,
        kRenderStuffSize: (id)CFBridgingRelease(CGSizeCreateDictionaryRepresentation(size))
    };
}

+ (NSDictionary *)makeRenderObject:(id)object withCenterPosition:(CGPoint)position {
    CGSize objectSize = CGSizeZero;
    
    if ([object isKindOfClass:[UIImage class]]) {
        UIImage *objectImage = object;
        objectSize = objectImage.size;
    }
    else if ([object isKindOfClass:[NSAttributedString class]]) {
        NSAttributedString *objectAttributedString = object;
        objectSize = objectAttributedString.size;
    }
    else if ([object isKindOfClass:[RenderStuffCircle class]]) {
        RenderStuffCircle *objectCircle = object;
        objectSize = CGSizeMake(objectCircle.radius * 2, objectCircle.radius * 2);
    }
    
    return @{
        kRenderStuffObject: object,
        kRenderStuffPosition: (id)CFBridgingRelease(CGPointCreateDictionaryRepresentation(CGPointMake(position.x - objectSize.width * .5, position.y - objectSize.height * .5)))
    };
}

- (UIImage *)tintedCopyWithTintColor:(UIColor *)color
{
    
    UIImage * image = self;
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [color setFill];
    CGContextFillRect(context, rect);
    
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}

@end
