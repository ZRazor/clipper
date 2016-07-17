//
//  MKRAUAudioFilePlayer.m
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAUAudioFilePlayer.h"

@implementation MKRAUAudioFilePlayer {
    AudioFileID file;
    NSString *filePath;
    AudioStreamBasicDescription format;
    UInt64 nPackets;
}

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier andType:kAudioUnitType_Generator andSubType:kAudioUnitSubType_AudioFilePlayer andManufacturer:kAudioUnitManufacturer_Apple];
    
    return self;
}

- (OSStatus)setupWithFilePath:(NSString *)path {
    filePath = path;
    CFURLRef URL = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    OSStatus err = AudioFileOpenURL(URL, kAudioFileReadPermission, 0, &file);
    if (err) {
        return err;
    }
    
    UInt32 propSize = sizeof(format);
    err = AudioFileGetProperty(file, kAudioFilePropertyDataFormat, &propSize, &format);
    if (err) {
        return err;
    }
    
    err =  AudioUnitSetProperty(self.unit, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &file, sizeof(file));
    if (err) {
        return err;
    }
    
    propSize = sizeof(nPackets);
    err = AudioFileGetProperty(file, kAudioFilePropertyAudioDataPacketCount, &propSize, &nPackets);
    if (err) {
        return err;
    }
    
    ScheduledAudioFileRegion rgn;
    memset(&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = file;
    rgn.mLoopCount = 0;
    rgn.mStartFrame = 0;
    rgn.mFramesToPlay = (UInt32)nPackets * format.mFramesPerPacket;
    _sampleTime = rgn.mFramesToPlay;
    
    err = [self setProperty:kAudioUnitProperty_ScheduledFileRegion inScope:kAudioUnitScope_Global to:&rgn withSize:sizeof(rgn)];
    if (err) {
        return err;
    }
    
    UInt32 defaultVal = 0;
    err = [self setProperty:kAudioUnitProperty_ScheduledFilePrime inScope:kAudioUnitScope_Global to:&defaultVal withSize:sizeof(defaultVal)];
    
    AudioTimeStamp startTime;
    memset(&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid;
    startTime.mSampleTime = 0;
    err = [self setProperty:kAudioUnitProperty_ScheduleStartTimeStamp inScope:kAudioUnitScope_Global to:&startTime withSize:sizeof(startTime)];
    if (err) {
        return err;
    }
    
    return noErr;
}

@end
