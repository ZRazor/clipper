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

static int const kMKRAudioSampleRate = 44100;
static int const kMKRAudioBitDepth = 16;
/**
 * Set VAD sensitivity (0-100):
 * - Lower values are for strong voice signals like for a cellphone or personal mic.
 * - Higher values are for use with a fixed-position mic or any application with voice buried in ambient noise.
 * - Defaults to 0
 */
static int const kMKRVadSensitivity = 0;
/**
 * Set the maximum length of time recorded by the VAD in ms
 * Set to -1 for no timeout
 * Defaults to 7000
 */
static int const kMKRVadTimeout = -1;

@interface MKRVad : NSObject

- (void)gotAudioSamples:(NSData *)samples;

@end
