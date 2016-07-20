//
// Created by Anton Zlotnikov on 20.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRFilterInstruction.h"

@interface MKRFiltersManager : NSObject


- (void)addInstruction:(MKRFilterInstruction *)instruction;

- (void)applyFiltersToBuffer:(CVPixelBufferRef)imageBuffer atMs:(double)time;
@end