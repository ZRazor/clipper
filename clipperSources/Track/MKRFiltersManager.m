//
// Created by Anton Zlotnikov on 20.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import "MKRFiltersManager.h"



@implementation MKRFiltersManager {
    NSMutableArray <MKRFilterInstruction *> *instructions;
    CIContext *context;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    instructions = [NSMutableArray new];
    context = [CIContext contextWithOptions:nil];

    return self;
}

- (void)addInstruction:(MKRFilterInstruction *)instruction {
    [instructions addObject:instruction];
}

- (void)applyFiltersToBuffer:(CVPixelBufferRef)imageBuffer atMs:(double)time {
    CIImage *image = nil;
    for (MKRFilterInstruction *instruction in instructions) {
        if ([instruction needToApplyAtMs:time]) {
            if (!image) {
                image = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
            }
            image = [instruction applyInstructionToImage:image atMs:time];
        }
    }
    if (image) {
        [context render:image toCVPixelBuffer:(CVPixelBufferRef)imageBuffer];
    }
}


@end