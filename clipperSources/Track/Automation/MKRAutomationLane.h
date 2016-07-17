//
//  MKRAutomationLane.h
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MKRAutomationPoint.h"

@interface MKRAutomationLane : NSObject

@property (nonatomic) NSInteger audioUnitIdentifier;
@property (nonatomic) AudioUnitParameterID parameterID;
@property (nonatomic) NSMutableArray<MKRAutomationPoint *> *points;

- (instancetype)initWithAudioUnitIdentifier:(NSInteger)audioUnitIdentifier andParameterID:(AudioUnitParameterID)parameterID;

- (void)addPointAt:(CMTime)time withValue:(NSNumber *)value;

- (void)prepare;

- (MKRAutomationPoint *)getPointBefore:(CMTime)time;
- (MKRAutomationPoint *)getPointAfterOrAt:(CMTime)time;

@end
