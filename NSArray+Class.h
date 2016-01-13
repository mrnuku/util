//
//  NSArray+Class.h
//  McK.HERO.Demo
//
//  Created by Bálint Róbert on 05/06/15.
//  Copyright (c) 2015 Incepteam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Class)

- (NSEnumerator *)objectEnumeratorForClass:(Class)clss;
- (NSArray *)objectsForClass:(Class)clss;

@end
