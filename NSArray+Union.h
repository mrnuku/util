//
//  NSArray+Union.h
//  FinTech
//
//  Created by Bálint Róbert on 07/08/15.
//  Copyright (c) 2015 IncepTech Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Union)

/** returns the two container union or intersection of objects
 * @param dictionary the reference container for the receiver array what used for the comparsion
 * @param dictionaryObjects determines which container provides the objects in the resulting array
 * @return NSArray with the resulting objects
 */
- (NSArray *)arrayOfUnionObjectsWithDictionary:(NSDictionary *)dictionary useObjectsFromDictionary:(BOOL)dictionaryObjects;

/** returns the two container union or intersection of objects
 * @param array the reference container for the receiver array what used for the comparsion
 * @param secondaryArrayObjects determines which container provides the objects in the resulting array
 * @return NSArray with the resulting objects
 */
- (NSArray *)arrayOfUnionObjectsWithArray:(NSArray *)array useObjectsFromSecondaryArray:(BOOL)secondaryArrayObjects;

/** returns the two container substraction of objects
 * @param array the reference container for the receiver array what used for the comparsionsecondaryArrayObjects
 * @return NSArray with the resulting objects
 */
- (NSArray *)arrayOfSubstractedObjectsWithArray:(NSArray *)array;

@end
