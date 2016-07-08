//
//  MKRProcessedInterval.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRInterval.h"

@interface MKRProcessedInterval : MKRInterval

@property (nonatomic) BOOL isMerge;
@property (nonatomic) double speedFactor;
@property (nonatomic) NSInteger quantsLength;
@property (nonatomic) double msLength;
@property (nonatomic) double warpedMsLength;

-(instancetype)initWithStart:(NSInteger)start andEnd:(NSInteger)end andSpeedFactor:(double)speedFactor andQuantsLength:(NSInteger)quantsLength andMsLength:(double)msLength andWarpedMsLength:(double)msLength;

@end
