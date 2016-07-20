//
// Created by Anton Zlotnikov on 20.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRBloomFilterInstruction.h"


@implementation MKRBloomFilterInstruction {
    CIFilter *filter;
}

- (void)prepareFilters {
    filter = [CIFilter filterWithName:@"CIBoxBlur"
                  withInputParameters: @{
                          @"inputRadius": @10,
                  }];
}

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}
@end