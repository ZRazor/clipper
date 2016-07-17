//
//  MKRAudioUnit.m
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRAudioUnit.h"

@implementation MKRAudioUnit

- (instancetype)initWithIdentifier:(NSInteger)identifier andType:(OSType)componentType andSubType:(OSType)componentSubType andManufacturer:(OSType)manufacturer {
    self = [super init];
    if (!self) {
        return nil;
    }
    AudioComponentDescription desc;
    
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentType = componentType;
    desc.componentSubType = componentSubType;
    desc.componentManufacturer = manufacturer;
    
    [self setDesc:desc];
    [self setIdentifier:identifier];
    
    return self;
}

- (instancetype)initWithIdentifier:(NSInteger)identifier {
    [self setIdentifier:identifier];
    
    return self;
}

- (OSStatus)addToGraph:(AUGraph)graph {
    return AUGraphAddNode(graph, &_desc, &_node);
}

- (OSStatus)graphNodeInfo:(AUGraph)graph {
    return AUGraphNodeInfo(graph, _node, NULL, &_unit);
}

- (OSStatus)setProperty:(AudioUnitPropertyID)propertyId inScope:(AudioUnitScope)scope to:(const void *)data withSize:(UInt32)size {
    return AudioUnitSetProperty(_unit, propertyId, scope, 0, data, size);
}

- (OSStatus)getProperty:(AudioUnitPropertyID)propertyId inScope:(AudioUnitScope)scope to:(void * _Nonnull)data withSize:(UInt32 * _Nonnull)size {
    return AudioUnitGetProperty(_unit, propertyId, scope, 0, data, size);
}

- (OSStatus)setParameter:(AudioUnitParameterID)parameterId to:(Float64)value {
    return AudioUnitSetParameter(_unit, parameterId, kAudioUnitScope_Global, 0, value, 0);
}

@end
