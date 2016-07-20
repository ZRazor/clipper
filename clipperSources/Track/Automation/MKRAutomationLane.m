//
//  MKRAutomationLane.m
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAutomationLane.h"

@implementation MKRAutomationLane

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setPoints:[[NSMutableArray alloc] init]];
    
    return self;
}

- (instancetype)initWithAudioUnitIdentifier:(NSInteger)audioUnitIdentifier andParameterID:(AudioUnitParameterID)parameterID {
    self = [self init];
    if (!self) {
        return nil;
    }
    [self setAudioUnitIdentifier:audioUnitIdentifier];
    [self setParameterID:parameterID];
    return self;
}

- (void)addPointAt:(CMTime)time withValue:(NSNumber *)value {
    MKRAutomationPoint *point = [[MKRAutomationPoint alloc] initWithTime:time andValue:value];
    [self.points addObject:point];
}

- (void)prepare {
    [self.points sortUsingComparator:^NSComparisonResult(MKRAutomationPoint *obj1, MKRAutomationPoint *obj2) {
        int32_t order = CMTimeCompare(obj1.position, obj2.position);
        if (order == 1) {
            return NSOrderedAscending;
        } else if (order == 0) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
}

- (MKRAutomationPoint *)getPointBefore:(CMTime)time {
    MKRAutomationPoint *currentPoint = nil;
    MKRAutomationPoint *result = nil;
    for (int i = (int)[self.points count] - 1; i >= 0; i--) {
        currentPoint = self.points[i];
        if (CMTimeGetSeconds(currentPoint.position) < CMTimeGetSeconds(time)) {
            result = currentPoint;
            break;
        }
    }
    
    return result;
}

- (MKRAutomationPoint *)getPointAfterOrAt:(CMTime)time {
    MKRAutomationPoint *currentPoint = nil;
    MKRAutomationPoint *result = nil;
    for (int i = 0; i < [self.points count]; i++) {
        currentPoint = self.points[i];
        if (CMTimeGetSeconds(currentPoint.position) >= CMTimeGetSeconds(time)) {
            result = currentPoint;
            break;
        }
    }
    
    return result;
}

@end
