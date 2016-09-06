//
//  MKRColorGlitchInstruction.m
//  clipper
//
//  Created by dev on 20.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRColorGlitchInstruction.h"

@implementation MKRColorGlitchInstruction {
    CIFilter *filter;
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
    int rFactor = 0, gFactor = 0, bFactor = 0;
    
    if (part < 0.25) {
        rFactor = 1;
        gFactor = 0.7;
        bFactor = 0.7;
    } else if (part >= 0.25 && part < 0.5) {
        rFactor = 0.7;
        gFactor = 1;
        bFactor = 0.7;
    } else if (part >= 0.5 && part < 0.75) {
        rFactor = 0.7;
        gFactor = 0.7;
        bFactor = 1;
    } else if (part >= 0.75) {
        rFactor = 0.7;
        gFactor = 0.7;
        bFactor = 0.7;
    }
    
    r = [CIVector vectorWithX:rFactor Y:0.7 Z:0.7];
    g = [CIVector vectorWithX:0.7 Y:gFactor Z:0.7];
    b = [CIVector vectorWithX:0.7 Y:0.7 Z:bFactor];
    bias = [CIVector vectorWithX:0 Y:0 Z:0 W:0];
    
    [filter setValue:r forKey:@"inputRVector"];
    [filter setValue:g forKey:@"inputGVector"];
    [filter setValue:b forKey:@"inputBVector"];
    [filter setValue:bias forKey:@"inputBiasVector"];
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}

@end
