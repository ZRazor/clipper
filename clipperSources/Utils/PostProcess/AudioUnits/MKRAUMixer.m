//
//  MKRAUMixer.m
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAUMixer.h"

@implementation MKRAUMixer {
    UInt32 inputElementCount;
    UInt32 inputMeteringMode;
    UInt32 globalMaximumFramesPerSlice;
    AudioStreamBasicDescription outputStreamFormat;
}

- (instancetype) initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier andType:kAudioUnitType_Mixer andSubType:kAudioUnitSubType_MultiChannelMixer andManufacturer:kAudioUnitManufacturer_Apple];
    
    return self;
}

- (OSStatus)setInputElementCount:(UInt32)count {
    inputElementCount = count;
    return [self setProperty:kAudioUnitProperty_ElementCount inScope:kAudioUnitScope_Input to:&inputElementCount withSize:sizeof(inputElementCount)];
}

- (OSStatus)setInputMeteringMode:(UInt32)mode {
    inputMeteringMode = mode;
    return [self setProperty:kAudioUnitProperty_MeteringMode inScope:kAudioUnitScope_Input to:&inputMeteringMode withSize:sizeof(inputMeteringMode)];
}

- (OSStatus)setGlobalMaximumFramesPerSlice:(UInt32)count {
    globalMaximumFramesPerSlice = count;
    return [self setProperty:kAudioUnitProperty_MaximumFramesPerSlice inScope:kAudioUnitScope_Global to:&globalMaximumFramesPerSlice withSize:sizeof(globalMaximumFramesPerSlice)];
}

- (OSStatus)setOutputStreamFormat:(AudioStreamBasicDescription)format {
    outputStreamFormat = format;
    return [self setProperty:kAudioUnitProperty_StreamFormat inScope:kAudioUnitScope_Output to:&outputStreamFormat withSize:sizeof(outputStreamFormat)];
}

@end
