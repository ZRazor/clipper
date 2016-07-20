//
// Created by Anton Zlotnikov on 20.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRFilterInstruction.h"

@interface MKRFilterInstruction()

@property (nonatomic) CIFilter *filter;
@property (nonatomic) double startTime;
@property (nonatomic) double endTime;

@end

@implementation MKRFilterInstruction {

}

- (instancetype)initWithStartTime:(double)startTime andEndTime:(double)endTime {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setStartTime:startTime];
    [self setEndTime:endTime];
    [self prepareFilters];

    return self;
}

- (void)prepareFilters {

}

- (BOOL)needToApplyAtMs:(double)time {
    return (time >= self.startTime && time <= self.endTime);
}

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    return image;
}

@end