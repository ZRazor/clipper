//
//  MKRColorFadeFilterInstruction.h
//  clipper
//
//  Created by dev on 01.09.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRFilterInstruction.h"

@interface MKRColorFadeFilterInstruction : MKRFilterInstruction

- (instancetype)initWithStartTime:(double)startTime andEndTime:(double)endTime andFadeIn:(BOOL)isFadeIn andThreshold:(double)_threshold;

- (instancetype)initWithStartTime:(double)startTime andEndTime:(double)endTime andFadeIn:(BOOL)isFadeIn;

@end
