//
//  MKRAUTimePitch.m
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAUTimePitch.h"

@implementation MKRAUTimePitch

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier andType:kAudioUnitType_FormatConverter andSubType:kAudioUnitSubType_NewTimePitch andManufacturer:kAudioUnitManufacturer_Apple];
    
    return self;
}

@end
