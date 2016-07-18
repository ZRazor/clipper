//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRScenesFillManager.h"
#import "MKRRawDataProcessor.h"
#import "MKRVad.h"
#import "MKRTrack.h"


@implementation MKRScenesFillManager {
    NSString *metaDataPath;
}

- (instancetype)initWithMetaDataPath:(NSString *)mDataPath {
    self = [super init];
    if (!self) {
        return nil;
    }
    metaDataPath = mDataPath;

    return self;
}

- (MKRTrack *)tryToFillScenesWithAsset:(AVAsset *)avAsset {
    NSArray *audioTracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    if (![audioTracks count]) {
        NSLog(@"No audio tracks found");
        return nil;
    }
    AVAssetTrack *audioTrack = audioTracks[0];

    NSData *audioData = [MKRRawDataProcessor audioRawDataForTrack:audioTrack withReaderSettings:@{
            AVSampleRateKey: @16000,
            AVLinearPCMBitDepthKey: @16,
            AVFormatIDKey: @(kAudioFormatLinearPCM),
            AVLinearPCMIsFloatKey: @NO
    }];

    CMTime audioDuration = avAsset.duration;
    NSInteger audioMsDuration = round(CMTimeGetSeconds(audioDuration) * 1000);

    MKRVad *vad = [[MKRVad alloc] initWithAudioSamples:audioData andAudioMsDuration:audioMsDuration];
    NSArray *timeouts = @[@3000, @2000, @1000, @500, @300];

    for (int i = (int)[timeouts count] - 1; i >= 0; i--) {
        NSNumber *timeout = timeouts[i];
        NSLog(@"Try to fill scenes with %d timeout", timeout.intValue);
        [vad setVadTimeout:timeout.intValue];
        NSMutableArray<MKRInterval *> *speechIntervals = [vad findSpeechIntervals];
        NSLog(@"VAD complete, found %lu speech intervals", [speechIntervals count]);
        for (MKRInterval *interval in speechIntervals) {
            NSLog(@"[%f, %f]", interval.start / 1000.0, interval.end / 1000.0);
        }
        MKRTrack *track = [[MKRTrack alloc] initWithMetaDataPath:metaDataPath andFeaturesInterval:speechIntervals];
        if ([track fillScenes]) {
            return track;
        }
    }
    
    return nil;

}

@end