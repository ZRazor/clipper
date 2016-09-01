//
//  MKRInterval.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRInterval.h"

@interface MKRInterval()

@property (readwrite, nonatomic) NSInteger start;
@property (readwrite, nonatomic) NSInteger end;
@property (readwrite, nonatomic) double averageGain;

@end

@implementation MKRInterval

- (instancetype)initWithStart:(NSInteger)start andEnd:(NSInteger)end andAverageGain:(double)averageGain {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setStart:start];
    [self setEnd:end];
    [self setAverageGain:averageGain];
    [self setUseCount:0];
    
    return self;
}

- (NSInteger)length {
    return self.end - self.start;
}

- (void)use {
    self.useCount++;
}

@end
