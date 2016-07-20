//
//  MKRAutomationPoint.m
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAutomationPoint.h"

@implementation MKRAutomationPoint

- (instancetype)initWithTime:(CMTime)time andValue:(NSNumber *)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setPosition:time];
    [self setValue:value];
    return self;
}

@end
