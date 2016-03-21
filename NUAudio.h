//
//  NUAudio.h
//  util
//
//  Created by mrnuku on 2015. 02. 21..
//  Copyright (c) 2015. scientefic_station2. All rights reserved.
//

#import "Manager.h"
#import <AudioToolbox/AudioToolbox.h>

enum {
    kAudioLoader_DefaultId = 1000
};

@interface NUAudioFile : NSObject

@property SystemSoundID soundId;

- (void)playAudioFile;

@end

@interface NUAudioManager : Manager

- (NUAudioFile *)loadAudioFile:(NSString *)fileName;
- (void)playAudioFile:(NSString *)fileName;

@end
