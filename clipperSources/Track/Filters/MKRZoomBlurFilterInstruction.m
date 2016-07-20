//
//  MKRZoomBlurFilterInstruction.m
//  clipper
//
//  Created by dev on 20.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRZoomBlurFilterInstruction.h"

@implementation MKRZoomBlurFilterInstruction {
    CIFilter *filter;
}

- (void)prepareFilters {
    filter = [CIFilter filterWithName:@"CIZoomBlur"
                  withInputParameters: @{
                                         @"inputAmount": @10,
                                         }];
}

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    Float64 totalDuration = fabs(self.endTime - self.startTime);
    Float64 currentDuration = time - self.startTime;
    Float64 part = currentDuration / totalDuration;
    Float64 maxAmount = 50;
    Float64 currentAmount = 0;
    
    if (part < 0.25) {
        currentAmount = part / 0.25 * 200;
    } else if (part >= 0.25 && part < 0.5) {
        currentAmount = (maxAmount - (part - 0.25) / 0.25 * maxAmount);
    } else if (part > 0.5) {
        currentAmount = (part - 0.5) / 0.5 * maxAmount;
    } else if (part >= 0.5 && part <= 1) {
        currentAmount = (maxAmount - (part - 0.5) / 0.5 * maxAmount);
    }

    [filter setValue:[CIVector vectorWithX:image.extent.size.width / 2.f Y:image.extent.size.height / 2.f] forKey:@"inputCenter"];
    [filter setValue:@(currentAmount) forKey:@"inputAmount"];
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}

@end
