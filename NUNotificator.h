//
//  NUNotificator.h
//  util
//
//  Created by Bálint Róbert on 21/03/16.
//  Copyright © 2016 mrnuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUNotificator<KeyType> : NSObject

/**
 Send notification event to all notification block paired with the given key
 @param userData optional data passed to the notification blocks
 @param key The trigger key
 */
- (void)sendNotificationWithUserData:(id)userData withKey:(KeyType <NSCopying>)key;

/**
 Specify your notification blocks with this method, and hold the returning reference strongly or nil it, if you want to disable the action block.
 @param notificationBlock The notification block you want to register.
 @param key The desired key what will trigger this notification block when invoked from sendNotificationWithUserData:withKey:
 */
- (id)addWeakNotificationBlock:(void (^)(id userData))notificationBlock withKey:(KeyType <NSCopying>)key;

/**
 Alternative method to disable your notification block. (you can spare your strongly held reference for later use for example)
 @param notificationBlock The action block you want to de-register
 @param key The trigger key
 */
- (void)removeWeakNotificationBlock:(id)notificationBlock withKey:(KeyType <NSCopying>)key;

/**
 Alternative method to disable your notification block. (you can spare your strongly held reference for later use for example)
 @param notificationBlock The action block you want to de-register
 */
- (void)removeWeakNotificationBlock:(id)notificationBlock;

@end
