//
//  MKRTemperatureAndTintFilterInstruction.m
//  clipper
//
//  Created by dev on 20.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRTemperatureAndTintFilterInstruction.h"

@implementation MKRTemperatureAndTintFilterInstruction {
    CIFilter *filter;
}

- (void)prepareFilters {
    filter = [CIFilter filterWithName:@"CITemperatureAndTint"
                  withInputParameters: @{
                                         @"inputNeutral": [CIVector vectorWithX:6500 Y:0],
                                         @"inputTargetNeutral": [CIVector vectorWithX:6500 Y:0]
                                         }];
}

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    Float64 totalDuration = fabs(self.endTime - self.startTime);
    Float64 currentDuration = time - self.startTime;
    Float64 part = currentDuration / totalDuration;
    Float64 maxValue = 15000;
    Float64 minValue = 6500;
    Float64 currentAmount = part * maxValue + minValue;
    
    [filter setValue:[CIVector vectorWithX:currentAmount Y:0] forKey:@"inputNeutral"];
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}

@end
