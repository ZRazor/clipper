//
//  MKRVolumeAnalyzer.m
//  clipper
//
//  Created by dev on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRVolumeAnalyzer.h"
#import "MKRRawDataProcessor.h"

@implementation MKRVolumeAnalyzer

+ (Float64)getAudioAverageVolumesRatioOfA:(NSURL *)aURL andB:(NSURL *)bURL {
    AVAsset *a = [AVAsset assetWithURL:aURL];
    AVAsset *b = [AVAsset assetWithURL:bURL];
    
    AVAssetTrack *aAssetTrack = [a tracksWithMediaType:AVMediaTypeAudio][0];
    AVAssetTrack *bAssetTrack = [b tracksWithMediaType:AVMediaTypeAudio][0];
    
    NSData *aData = [MKRRawDataProcessor audioRawDataForTrack:aAssetTrack withReaderSettings:@{
                                                                                     AVSampleRateKey: @(16000),
                                                                                     AVLinearPCMBitDepthKey: @(16),
                                                                                     AVFormatIDKey: @(kAudioFormatLinearPCM),
                                                                                     AVLinearPCMIsFloatKey: @NO
                                                                                     }];
    NSData *bData = [MKRRawDataProcessor audioRawDataForTrack:bAssetTrack withReaderSettings:@{
                                                                                     AVSampleRateKey: @(16000),
                                                                                     AVLinearPCMBitDepthKey: @(16),
                                                                                     AVFormatIDKey: @(kAudioFormatLinearPCM),
                                                                                     AVLinearPCMIsFloatKey: @NO
                                                                                     }];
    short *bytes = (short*)[aData bytes];
    unsigned int size =  (unsigned int) aData.length / sizeof(short);
    long long bytesSum = 0;
    for (int bytesOffset = 0; bytesOffset < size; bytesOffset++) {
        bytesSum += abs(bytes[bytesOffset]);
    }
    float aVolume = bytesSum / size;
    
    bytes = (short *)[bData bytes];
    size = (unsigned int) bData.length / sizeof(short);
    bytesSum = 0;
    for (int bytesOffset = 0; bytesOffset < size; bytesOffset++) {
        bytesSum += abs(bytes[bytesOffset]);
    }
    float bVolume = bytesSum / size;
    
    return aVolume / bVolume;
}

@end
