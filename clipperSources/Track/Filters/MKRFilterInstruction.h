//
// Created by Anton Zlotnikov on 20.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface MKRFilterInstruction : NSObject

@property (nonatomic) double startTime;
@property (nonatomic) double endTime;

- (instancetype)initWithStartTime:(double)startTime andEndTime:(double)endTime;

- (void)prepareFilters;

- (BOOL)needToApplyAtMs:(double)time;

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time;
@end