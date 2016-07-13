//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MKRRawDataProcessor : NSObject


+ (Float64)sampleRateForTrack:(AVAssetTrack *)track;

+ (UInt32)bitsDepthForTrack:(AVAssetTrack *)track;

+ (NSData *)audioRawDataForTrack:(AVAssetTrack *)track withReaderSettings:(NSDictionary *)settings;
@end