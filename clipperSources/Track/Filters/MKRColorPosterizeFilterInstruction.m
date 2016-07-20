//
//  MKRColorPosterizeFilterInstruction.m
//  clipper
//
//  Created by dev on 20.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRColorPosterizeFilterInstruction.h"

@implementation MKRColorPosterizeFilterInstruction {
    CIFilter *filter;
}

- (void)prepareFilters {
    filter = [CIFilter filterWithName:@"CIColorPosterize"
                  withInputParameters: @{
                                         @"inputLevels": @6,
                                         }];
}

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    Float64 totalDuration = fabs(self.endTime - self.startTime);
    Float64 currentDuration = time - self.startTime;
    Float64 part = currentDuration / totalDuration;
    Float64 maxAmount = 13;
    Float64 minAmount = 4;
    Float64 currentAmount = maxAmount - maxAmount * part + minAmount;
    
    [filter setValue:@(currentAmount) forKey:@"inputLevels"];
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}

@end
