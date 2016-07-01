//
//  NSObject+PropertyReflection.h
//  util
//
//  Created by mrnuku on 28/05/16.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (PropertyReflection)

/**
 Lists all property names with objective c runtime.
 */
+ (NSArray<NSString *> *)listPropertyNames:(BOOL)excludeReadOnly;
- (id)reflectedCopy;
- (NSString *)reflectedDescription;

@end
