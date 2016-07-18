//
//  MKRAudioUnit.h
//  clipper
//
//  Created by dev on 17.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MKRAudioUnit : NSObject

@property (nonatomic) AUNode node;
@property (nonatomic) _Nullable AudioUnit unit;
@property (nonatomic) AudioComponentDescription desc;
@property (nonatomic) NSInteger identifier;

- (_Nullable instancetype)initWithIdentifier:(NSInteger)identifier andType:(OSType)componentType andSubType:(OSType)componentSubType andManufacturer:(OSType)manufacturer;

- (_Nullable instancetype)initWithIdentifier:(NSInteger)identifier;

- (OSStatus)addToGraph:(_Nonnull AUGraph)graph;

- (OSStatus)graphNodeInfo:(_Nonnull AUGraph)graph;

- (OSStatus)setProperty:(AudioUnitPropertyID)propertyId inScope:(AudioUnitScope)scope to:(const void * __nullable)data withSize:(UInt32)size;

- (OSStatus)getProperty:(AudioUnitPropertyID)propertyId inScope:(AudioUnitScope)scope to:(void * _Nonnull)data withSize:(UInt32 * _Nonnull)size;

- (OSStatus)setParameter:(AudioUnitParameterID)parameterId inScope:(AudioUnitScope)scope to:(Float64)value;

- (OSStatus)setParameter:(AudioUnitParameterID)parameterId inScope:(AudioUnitScope)scope ofElement:(AudioUnitElement)element to:(Float64)value;

@end
