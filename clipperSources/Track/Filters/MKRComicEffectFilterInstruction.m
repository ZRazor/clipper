//
//  MKRComicEffectFilterInstruction.m
//  clipper
//
//  Created by dev on 02.09.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRComicEffectFilterInstruction.h"

@implementation MKRComicEffectFilterInstruction {
    CIFilter *filter;
}

- (void)prepareFilters {
    filter = [CIFilter filterWithName:@"CIComicEffect"
                  withInputParameters: @{}];
}

- (CIImage *)applyInstructionToImage:(CIImage *)image atMs:(double)time {
    [filter setValue:image forKey:kCIInputImageKey];
    return [filter outputImage];
}

@end
