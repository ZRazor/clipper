//
//  MKRColorFadeFilterInstruction.m
//  clipper
//
//  Created by dev on 01.09.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRColorFadeFilterInstruction.h"

@implementation MKRColorFadeFilterInstruction {
    CIFilter *filter;
    BOOL fadeIn;
}

- (instancetype)initWithStartTime:(double)startTime andEndTime:(double)endTime andFadeIn:(BOOL)isFadeIn {
    self = [super initWithStartTime:startTime andEndTime:endTime];
    if (!self) {
        return nil;
    }
    fadeIn = isFadeIn;

    return self;
}

- (void)prepareFilters {
    filter = [CIFilter filterWithName:@"CIColorMatrix"
                  withInputParameters: @{
                                         @"inputRVector": [CIVector vectorWithX:-1 Y:0 Z:0],
                                         @"inputGVector": [CIVector vectorWithX:0 Y:-1 Z:0],
                                         @"inputBVector": [CIVector vectorWithX:0 Y:0 Z:-1],
                                         @"inputBiasVector": [CIVector vectorWithX:1 Y:1 Z:1],
                                         }];
}



- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    Float64 totalDuration = fabs(self.endTime - self.startTime);
    Float64 currentDuration = time - self.startTime;
    Float64 part = currentDuration / totalDuration;
    CIVector *r, *g, *b, *bias;
    Float64 rFactor = part, gFactor = part, bFactor = part;
    if (part > 0.8) {
        rFactor = 1;
        gFactor = 1;
        bFactor = 1;
    }
    if (!fadeIn) {
        rFactor = 1 - rFactor;
        gFactor = 1 - gFactor;
        bFactor = 1 - bFactor;
    }
    r = [CIVector vectorWithX:rFactor Y:0 Z:0];
    g = [CIVector vectorWithX:0 Y:gFactor Z:0];
    b = [CIVector vectorWithX:0 Y:0 Z:bFactor];
    bias = [CIVector vectorWithX:0 Y:0 Z:0 W:0];

    [filter setValue:r forKey:@"inputRVector"];
    [filter setValue:g forKey:@"inputGVector"];
    [filter setValue:b forKey:@"inputBVector"];
    [filter setValue:bias forKey:@"inputBiasVector"];
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}


@end
