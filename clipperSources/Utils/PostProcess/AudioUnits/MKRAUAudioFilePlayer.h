//
//  MKRAUAudioFilePlayer.h
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRAudioUnit.h"

@interface MKRAUAudioFilePlayer : MKRAudioUnit

@property (readonly, nonatomic) Float64 sampleTime;

- (OSStatus)setupWithFilePath:(NSString *)path;

@end
