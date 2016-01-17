//
//  OKOMutableWeakArray.m
//  McK.HERO.Demo
//
//  Created by Kocsis Olivér on 2015. 07. 07..
//  Copyright (c) 2015. Kocsis Oliver. All rights reserved.
//

#import "OKOMutableWeakArray.h"

@interface OKOMutableWeakArray ()

@property (nonatomic, strong) NSMutableArray * backingArray;

@end

@implementation OKOMutableWeakArray

#pragma mark - helpers

typedef id (^WeakReferenceInABlock)(void);

WeakReferenceInABlock wrapObjectInBlockAsWeak (id object) {
    __weak id weakref = object;
    return ^{ return weakref; };
}

id unwrapBlock (WeakReferenceInABlock block) {
    id retObj = nil;
    
    if (block) {
        retObj = block();
    }
    
    return retObj;
}
#pragma mark - Public API
-(void) compact {
    NSIndexSet * indexes = [super indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return obj == nil;
    }];
    [super removeObjectsAtIndexes:indexes];
}

-(void) removeNilObjects {
    [self compact];
}

#pragma mark - NSArray overrides

- (instancetype)init
{
    self = [super init];
    if (self) {
        _backingArray = [NSMutableArray new];
    }
    return self;
}

-(id)objectAtIndex:(NSUInteger)index {
    return unwrapBlock([_backingArray objectAtIndex:index]);
}

-(NSUInteger)count {
    return [_backingArray count];
}

#pragma mark - NSMutableArray overrides
-(void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [_backingArray insertObject:wrapObjectInBlockAsWeak(anObject) atIndex:index];
}

-(void)removeObjectAtIndex:(NSUInteger)index {
    [_backingArray removeObjectAtIndex:index];
}

-(void)addObject:(id)anObject {
    [_backingArray addObject:wrapObjectInBlockAsWeak(anObject)];
}

-(void)removeLastObject {
    [_backingArray removeLastObject];
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [_backingArray replaceObjectAtIndex:index withObject:wrapObjectInBlockAsWeak(anObject)];
}

-(NSString *)description {
    return [_backingArray description];
}

- (id)addObjectReturnRef:(nullable id)anObject {
    id objCopy = anObject;
    [_backingArray addObject:wrapObjectInBlockAsWeak(objCopy)];
    return objCopy;
}

@end
