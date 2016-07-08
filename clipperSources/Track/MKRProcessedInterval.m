//
//  MKRProcessedInterval.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRProcessedInterval.h"

@implementation MKRProcessedInterval

-(instancetype)initWithStart:(NSInteger)start andEnd:(NSInteger)end andSpeedFactor:(double)speedFactor andQuantsLength:(NSInteger)quantsLength andMsLength:(double)msLength andWarpedMsLength:(double)warpedMsLength {
    self = [super initWithStart:start andEnd:end];
    if (!self) {
        return nil;
    }
    [self setSpeedFactor:speedFactor];
    [self setQuantsLength:quantsLength];
    [self setMsLength:msLength];
    [self setWarpedMsLength:warpedMsLength];
    
    return self;
}

@end
