//
//  MKRAUGenericOutput.m
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAUGenericOutput.h"

@implementation MKRAUGenericOutput

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super initWithIdentifier:identifier andType:kAudioUnitType_Output andSubType:kAudioUnitSubType_GenericOutput andManufacturer:kAudioUnitManufacturer_Apple];
    
    return self;
}

@end
