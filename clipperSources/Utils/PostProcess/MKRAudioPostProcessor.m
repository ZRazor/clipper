//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRAudioPostProcessor.h"
#import "MKRRawDataProcessor.h"


@implementation MKRAudioPostProcessor {

}

+ (AVMutableAudioMix *)postProcessAudioForMutableComposition:(AVMutableComposition *)composition {
    //settings for tracks in future export
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    NSMutableArray *inputParams = [NSMutableArray new];

    for (AVMutableCompositionTrack *audioTrack in [composition tracksWithMediaType:AVMediaTypeAudio]) {
        NSData *audioData = [MKRRawDataProcessor audioRawDataForTrack:audioTrack withReaderSettings:@{
                AVSampleRateKey: @(16000),
                AVLinearPCMBitDepthKey: @(16),
                AVFormatIDKey: @(kAudioFormatLinearPCM),
                AVLinearPCMIsFloatKey: @NO
        }];

        short *bytes = (short*)[audioData bytes];
        unsigned int size =  (unsigned int) audioData.length / sizeof(short);
        long long bytesSum = 0;
        for (int bytesOffset = 0; bytesOffset < size; bytesOffset++) {
            bytesSum += abs(bytes[bytesOffset]);
        }
        float averageVolume = bytesSum / size;
        NSLog(@"Average volume: %f", averageVolume);
        AVMutableAudioMixInputParameters *mixParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        [mixParams setVolume:0.5f * (1000.f / averageVolume) atTime:kCMTimeZero];
        [inputParams addObject:mixParams];
    }

    [audioMix setInputParameters:inputParams];

    return audioMix;

}


@end