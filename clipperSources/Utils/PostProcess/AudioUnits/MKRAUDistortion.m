//
//  MKRAUDistortion.m
//  clipper
//
//  Created by dev on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAUDistortion.h"

@implementation MKRAUDistortion

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier andType:kAudioUnitType_Effect andSubType:kAudioUnitSubType_Distortion andManufacturer:kAudioUnitManufacturer_Apple];
    
    return self;
}

@end
