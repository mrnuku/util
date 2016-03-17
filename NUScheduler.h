//
//  NUScheduler.h
//  util
//
//  Created by Bálint Róbert on 17/03/16.
//  Copyright © 2016 mrnuku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NUScheduler : NSObject

/**
 The scheduler counter, what is incremented by the method of incerementCounter.
 */
@property (nonatomic, readonly) NSInteger counter;

/**
 The scheduler counter limiter value. When the counter reaches this, the scheduler will fire a completion event to all action blocks.
 Setting this value zero or less disables the counter event firing logic.
 */
@property (nonatomic) NSInteger counterLimit;

/**
 The scheduler fallback timer interval controlls an internal timer, what will fire an event if the counter fails to increment in this specified time interval.
 */
@property (nonatomic) NSTimeInterval fallbackTimerInterval;

/**
 Optionally used user supplemented data.
 */
@property (nonatomic, strong) id userData;

/**
 The main event driving method. Call this to incerement the counter by one, when the limit value reached, this will fire the action blocks, on the same thread what this method called from.
 */
- (void)incerementCounter;

/**
 Specify your action blocks with this method, and hold the returning reference strongly or nil it, if you want to disable the action block.
 @param actionBlock The action block you want to register.
 */
- (id)addWeakActionBlock:(void (^)(NUScheduler *scheduler))actionBlock;

/**
 Alternative method to disable your action block. (you can spare your strongly held reference for later use for example)
 @param actionBlock The action block you want to de-register
 */
- (void)removeWeakActionBlock:(id)actionBlock;

@end
