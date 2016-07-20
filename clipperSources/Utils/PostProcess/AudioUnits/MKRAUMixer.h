//
//  MKRAUMixer.h
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRAudioUnit.h"

@interface MKRAUMixer : MKRAudioUnit

- (OSStatus)setInputElementCount:(UInt32)count;
- (OSStatus)setInputMeteringMode:(UInt32)mode;

- (OSStatus)setGlobalMaximumFramesPerSlice:(UInt32)count;
- (OSStatus)setOutputStreamFormat:(AudioStreamBasicDescription)format;

@end
