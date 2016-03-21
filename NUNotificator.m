//
//  NUNotificator.m
//  util
//
//  Created by Bálint Róbert on 21/03/16.
//  Copyright © 2016 mrnuku. All rights reserved.
//

#import "NUNotificator.h"
#import "OKOMutableWeakArray.h"

@implementation NUNotificator {
    NSMutableDictionary *_taggedNotificatorsDict;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _taggedNotificatorsDict = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)sendNotificationWithUserData:(id)userData withKey:(id <NSCopying>)key {
    OKOMutableWeakArray *notificators = [_taggedNotificatorsDict objectForKey:key];
    [notificators compact];
    
    for (void (^notificationBlock)(id) in notificators) {
        notificationBlock(userData);
    }
}

- (id)addWeakNotificationBlock:(void (^)(id userData))notificationBlock withKey:(id <NSCopying>)key {
    OKOMutableWeakArray *notificators = [_taggedNotificatorsDict objectForKey:key];
    [notificators compact];
    
    if (!notificators) {
        notificators = [OKOMutableWeakArray new];
        [_taggedNotificatorsDict setObject:notificators forKey:key];
    }
    
    return [notificators addObjectReturnRef:notificationBlock];
}

- (void)removeWeakNotificationBlock:(id)notificationBlock withKey:(id <NSCopying>)key {
    OKOMutableWeakArray *notificators = [_taggedNotificatorsDict objectForKey:key];
    [notificators compact];
    [notificators removeObject:notificationBlock];
}

- (void)removeWeakNotificationBlock:(id)notificationBlock {
    [_taggedNotificatorsDict enumerateKeysAndObjectsUsingBlock:^(id <NSCopying> key, OKOMutableWeakArray *notificators, BOOL *stop) {
        NSUInteger index = [notificators indexOfObject:notificationBlock];
        
        if (index != NSNotFound) {
            [notificators removeObjectAtIndex:index];
            *stop = YES;
        }
    }];
}

@end
