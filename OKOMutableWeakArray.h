//
//  OKOMutableWeakArray.h
//  McK.HERO.Demo
//
//  Created by Kocsis Olivér on 2015. 07. 07..
//  Copyright (c) 2015. Kocsis Oliver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OKOMutableWeakArray : NSMutableArray
-(void) compact;
-(void) removeNilObjects; // same as compact

#pragma mark - NSArray overrides
- (nonnull instancetype)init;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability"
-(nullable id)objectAtIndex:(NSUInteger)index;
#pragma clang diagnostic pop

-(NSUInteger)count;

#pragma mark - NSMutableArray overrides
-(void)insertObject:(nullable id)anObject atIndex:(NSUInteger)index;

-(void)removeObjectAtIndex:(NSUInteger)index ;

-(void)addObject:(nullable id)anObject ;

-(void)removeLastObject;

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(nullable id)anObject ;

// required for proper block lifetime management
- (nonnull id)addObjectReturnRef:(nullable id)anObject;

@end
