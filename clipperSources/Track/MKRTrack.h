//
//  MKRTrack.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MKRBarManager.h"
#import "MKRAudioUnits.h"
#import "MKRAutomationLane.h"
#import "MKRFiltersManager.h"

@interface MKRTrack : NSObject

@property (nonatomic) NSInteger BPM;
@property (nonatomic) NSInteger QPB;
@property (nonatomic) double MSPQ;
@property (nonatomic) NSMutableArray<MKRAutomationLane *> *automations;
@property (nonatomic) MKRFiltersManager *filtersManager;

- (instancetype)initWithMetaDataPath:(NSString *)metaDataPath andFeaturesInterval:(NSMutableArray<MKRInterval *> *)features;
- (BOOL)fillScenes;
- (AVMutableComposition *)processVideo:(AVAsset *)original;
- (void)prepareAutomations;

@end
