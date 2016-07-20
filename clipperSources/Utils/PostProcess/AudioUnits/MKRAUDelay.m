//
//  MKRAUDelay.m
//  clipper
//
//  Created by dev on 18.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAUDelay.h"

@implementation MKRAUDelay

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier andType:kAudioUnitType_Effect andSubType:kAudioUnitSubType_Delay andManufacturer:kAudioUnitManufacturer_Apple];
    
    return self;
}

@end
