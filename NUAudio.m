//
//  NUAudio.m
//  util
//
//  Created by mrnuku on 2015. 02. 21..
//  Copyright (c) 2015. scientefic_station2. All rights reserved.
//

#import "NUAudio.h"

@implementation NUAudioFile

- (void)playAudioFile {
    AudioServicesPlaySystemSound(self.soundId);
}

@end

@implementation NUAudioManager {
    NSMutableDictionary *_audioFilesDict;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _audioFilesDict = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)dealloc {
    [_audioFilesDict enumerateKeysAndObjectsUsingBlock:^(NSString *fileName, NUAudioFile *audioFile, BOOL *stop) {
        if(audioFile.soundId != kAudioLoader_DefaultId) {
            AudioServicesDisposeSystemSoundID(audioFile.soundId);
        }
    }];
}

- (NUAudioFile *)loadAudioFile:(NSString *)fileName {
    NUAudioFile *audioFile = [_audioFilesDict objectForKey:fileName];
    
    if(!audioFile) {
        NSString *pathExt = fileName.pathExtension;
        NSString *pathWithoutExt = [fileName stringByDeletingPathExtension];
        NSString *path = [[NSBundle mainBundle] pathForResource:pathWithoutExt ofType:pathExt];
        SystemSoundID soundId;
        
        if(path.length) {
            NSURL* url = [NSURL fileURLWithPath:path];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundId);
        }
        else {
            soundId = kAudioLoader_DefaultId;
        }
        
        audioFile = [NUAudioFile new];
        audioFile.soundId = soundId;
        [_audioFilesDict setObject:audioFile forKey:fileName];
    }
    
    return audioFile;
}

- (void)playAudioFile:(NSString *)fileName {
    NUAudioFile *audioFile = [self loadAudioFile:fileName];
    [audioFile playAudioFile];
}

@end
