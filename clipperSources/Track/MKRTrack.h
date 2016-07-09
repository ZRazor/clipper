//
//  MKRTrack.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRBarManager.h"

@interface MKRTrack : NSObject

@property (nonatomic) NSInteger BPM;
@property (nonatomic) NSInteger QPB;
@property (nonatomic) double MSPQ;

-(instancetype)initWithMetaDataPath:(NSString *)metaDataPath andFeaturesInterval:(NSMutableArray<MKRInterval *> *)features;
-(BOOL)fillScenes;

@end
