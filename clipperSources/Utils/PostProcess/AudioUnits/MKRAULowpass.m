//
//  MKRAULowpass.m
//  clipper
//
//  Created by dev on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAULowpass.h"

@implementation MKRAULowpass

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier andType:kAudioUnitType_Effect andSubType:kAudioUnitSubType_LowPassFilter andManufacturer:kAudioUnitManufacturer_Apple];
    
    return self;
}

@end
