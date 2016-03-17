//
//  NUScheduler.m
//  util
//
//  Created by Bálint Róbert on 17/03/16.
//  Copyright © 2016 mrnuku. All rights reserved.
//

#import "NUScheduler.h"
#import "OKOMutableWeakArray.h"

@interface NUScheduler()

@property (nonatomic) NSInteger counter;
@property (nonatomic, strong) NSTimer *fallbackTimer;
@property (nonatomic, strong) OKOMutableWeakArray *actionBlocks;

@end

@implementation NUScheduler

@synthesize counterLimit = _counterLimit;
@synthesize fallbackTimerInterval = _fallbackTimerInterval;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _actionBlocks = [OKOMutableWeakArray new];
    }
    
    return self;
}

- (void)dealloc {
    [self _killFallbackTimer];
}

#pragma mark - internal stuff

- (void)_killFallbackTimer {
    [_fallbackTimer invalidate];
    _fallbackTimer = nil;
}

- (void)_notifyActionBlocks {
    [_actionBlocks compact];
    
    for (void (^actionBlock)(NUScheduler *) in _actionBlocks) {
        actionBlock(self);
    }
}

- (void)_reinitFallbackTimer {
    [self _killFallbackTimer];
    
    if (_fallbackTimerInterval > 0) {
        _fallbackTimer = [NSTimer scheduledTimerWithTimeInterval:_fallbackTimerInterval target:self selector:@selector(_doLoop) userInfo:nil repeats:NO];
    }
}

- (void)_checkCounter {
    if (_counterLimit > 0 && _counter >= _counterLimit) {
        [self _doLoop];
    }
}

- (void)_doLoop {
    [self _notifyActionBlocks];
    _counter = 0;
}

#pragma mark - custom setters

- (void)setCounterLimit:(NSInteger)counterLimit {
    _counterLimit = counterLimit;
    [self _checkCounter];
}

- (void)setFallbackTimerInterval:(NSTimeInterval)fallbackTimerInterval {
    _fallbackTimerInterval = fallbackTimerInterval;
    [self _reinitFallbackTimer];
}

#pragma mark - public interface

- (void)incerementCounter {
    _counter++;
    [self _checkCounter];
    [self _reinitFallbackTimer];
}

- (id)addWeakActionBlock:(void (^)(NUScheduler *))actionBlock {
    [_actionBlocks compact];
    return [_actionBlocks addObjectReturnRef:actionBlock];
}

- (void)removeWeakActionBlock:(id)actionBlock {
    [_actionBlocks removeObject:actionBlock];
    [_actionBlocks compact];
}

@end
