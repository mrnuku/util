//
//  NSArray+Union.m
//  FinTech
//
//  Created by Bálint Róbert on 07/08/15.
//  Copyright (c) 2015 IncepTech Ltd. All rights reserved.
//

#import "NSArray+Union.h"

@implementation NSArray (Union)

- (NSArray *)arrayOfUnionObjectsWithDictionary:(NSDictionary *)dictionary useObjectsFromDictionary:(BOOL)dictionaryObjects {
    NSMutableArray *unificated = [[NSMutableArray alloc] initWithCapacity:MIN(self.count, dictionary.count)];
    
    // use the smaller container for linear search for best performance
    if (dictionary.count < self.count) {
        NSArray* objectList = dictionary.objectEnumerator.allObjects;
        
        for (id object in self) {
            
            NSUInteger idx = [objectList indexOfObject:object];
            
            if (idx != NSNotFound) {
                [unificated addObject:dictionaryObjects ? [objectList objectAtIndex:idx] : object];
            }
        }
    }
    else {
        
        for (id object in dictionary.objectEnumerator) {
            
            NSUInteger idx = [self indexOfObject:object];
            
            if (idx != NSNotFound) {
                [unificated addObject:dictionaryObjects ? object : [self objectAtIndex:idx]];
            }
        }
    }
    
    return unificated.copy;
}

- (NSArray *)arrayOfUnionObjectsWithArray:(NSArray *)array useObjectsFromSecondaryArray:(BOOL)secondaryArrayObjects {
    NSMutableArray *unificated = [[NSMutableArray alloc] initWithCapacity:MIN(self.count, array.count)];
    
    // use the smaller container for linear search for best performance
    if (array.count < self.count) {
        for (id object in self) {
            
            NSUInteger idx = [array indexOfObject:object];
            
            if (idx != NSNotFound) {
                [unificated addObject:secondaryArrayObjects ? [array objectAtIndex:idx] : object];
            }
        }
    }
    else {
        
        for (id object in array) {
            
            NSUInteger idx = [self indexOfObject:object];
            
            if (idx != NSNotFound) {
                [unificated addObject:secondaryArrayObjects ? object : [self objectAtIndex:idx]];
            }
        }
    }
    
    return unificated.copy;
}

- (NSArray *)arrayOfSubstractedObjectsWithArray:(NSArray *)array {
    if (array.count > self.count) {
#ifdef TestLog
        TestLog(@"%@ %@: using inverse substraction", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
#endif
        return [array arrayOfSubstractedObjectsWithArray:self];
    }
    
    NSMutableArray *substracted = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    for (id object in self) {
        
        NSUInteger idx = [array indexOfObject:object];
        
        if (idx == NSNotFound) {
            [substracted addObject:object];
        }
    }
    
    return substracted.copy;
}

@end
