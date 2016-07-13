//
// Created by Anton Zlotnikov on 13.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class MKRTrack;

@interface MKRScenesFillManager : NSObject
- (instancetype)initWithMetaDataPath:(NSString *)mDataPath;

- (MKRTrack *)tryToFillScenesWithAsset:(AVAsset *)avAsset;
@end