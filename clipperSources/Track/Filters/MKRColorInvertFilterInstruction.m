//
// Created by Anton Zlotnikov on 20.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRColorInvertFilterInstruction.h"


@implementation MKRColorInvertFilterInstruction {
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
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}

@end