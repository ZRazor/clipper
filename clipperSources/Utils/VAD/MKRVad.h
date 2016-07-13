//
//  MKRVad.h
//  MKR
//
//  Created by Aric Lasry on 8/6/14.
//  Copyright (c) 2014 Willy Blandin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "MKRCVad.h"
#import "MKRInterval.h"

@interface MKRVad : NSObject

- (instancetype)initWithAudioSamples:(NSData *)aSamples andAudioMsDuration:(NSInteger)aMsDuration;

- (NSMutableArray<MKRInterval *> *)findSpeechIntervals;

- (void)setVadTimeout:(int)newTimeout;

- (void)setVadSensitivity:(int)newSensitivity;
@end
