//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MKRAudioPostProcessor : NSObject

+ (AVMutableAudioMix *)postProcessAudioForMutableComposition:(AVMutableComposition *)composition;

@end