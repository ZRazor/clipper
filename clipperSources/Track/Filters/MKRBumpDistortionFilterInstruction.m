//
// Created by Anton Zlotnikov on 20.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRBumpDistortionFilterInstruction.h"


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
    return [filter outputImage];
}

@end