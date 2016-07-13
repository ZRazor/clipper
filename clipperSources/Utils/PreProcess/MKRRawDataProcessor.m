//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRRawDataProcessor.h"


@implementation MKRRawDataProcessor {

}

+ (Float64)sampleRateForTrack:(AVAssetTrack *)track {
    NSArray* formatDesc = track.formatDescriptions;
    if (![formatDesc count]) {
        return 0;
    }
    CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef) formatDesc[0];
    const AudioStreamBasicDescription* bobTheDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
    return bobTheDesc->mSampleRate;
}

+ (UInt32)bitsDepthForTrack:(AVAssetTrack *)track {
    NSArray* formatDesc = track.formatDescriptions;
    if (![formatDesc count]) {
        return 0;
    }
    CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef) formatDesc[0];
    const AudioStreamBasicDescription* bobTheDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
    return bobTheDesc->mBitsPerChannel ?: 16;

}

+ (NSData *)audioRawDataForTrack:(AVAssetTrack *)track withReaderSettings:(NSDictionary *)settings {
    AVAssetReaderTrackOutput* readerOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:settings];
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:track.asset error:nil];
    [reader addOutput:readerOutput];
    [reader startReading];

    CMSampleBufferRef sample = [readerOutput copyNextSampleBuffer];
    NSMutableData *audioData =[[NSMutableData alloc] init];
    while (sample != NULL) {
        AudioBufferList audioBufferList;
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer( sample );
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sample, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);

        for (int y = 0; y < audioBufferList.mNumberBuffers; y++) {
            AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
            Float32 *frame = (Float32*)audioBuffer.mData;
            [audioData appendBytes:frame length:audioBuffer.mDataByteSize];
        }
        CFRelease(blockBuffer);
        blockBuffer=NULL;
        CFRelease(sample);
        sample = [readerOutput copyNextSampleBuffer];
    }

    return audioData;
}

@end