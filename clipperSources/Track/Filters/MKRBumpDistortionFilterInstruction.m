//
// Created by Anton Zlotnikov on 20.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRBumpDistortionFilterInstruction.h"
#import <stdlib.h>


@implementation MKRBumpDistortionFilterInstruction  {
    CIFilter *filter;
}

- (void)prepareFilters {
    filter = [CIFilter filterWithName:@"CIBumpDistortion"
                  withInputParameters: @{
                          @"inputRadius": @300,
                  }];
}

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    [filter setValue:image forKey:kCIInputImageKey];
    
    Float64 totalDuration = fabs(self.endTime - self.startTime);
    Float64 currentDuration = time - self.startTime;
    Float64 part = currentDuration / totalDuration;
    Float64 maxValue = 1;
    Float64 minValue = 0.5;
    Float64 currentAmount = part * (maxValue - minValue) + minValue;
    Float64 radius = arc4random_uniform(200) + 200;
    
    [filter setValue:[CIVector vectorWithX:image.extent.size.width / 2.f Y:image.extent.size.height / 2.f] forKey:@"inputCenter"];
    [filter setValue:@(currentAmount) forKey:@"inputScale"];
    [filter setValue:@(radius) forKey:@"inputRadius"];
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
    
    return [filter outputImage];
}

@end