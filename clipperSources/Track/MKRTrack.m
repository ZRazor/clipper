//
//  MKRTrack.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRTrack.h"
#import "MKRScene.h"
#import "MKRSceneA.h"
#import "MKRSceneB.h"

@implementation MKRTrack {
    NSMutableArray<MKRScene *> *scenes;
    NSMutableArray<MKRScene *> *structure;
    MKRBarManager *barManager;
}

-(instancetype)initWithMetaDataPath:(NSString *)metaDataPath andFeaturesInterval:(NSMutableArray<MKRInterval *> *)features{
    self = [super init];
    if (!self) {
        return nil;
    }
    scenes = [NSMutableArray<MKRScene *> new];
    structure = [NSMutableArray<MKRScene *> new];
    
    NSDictionary *metaData = [[NSDictionary alloc] initWithContentsOfFile:metaDataPath];
    [self setBPM:[[metaData valueForKey:@"BPM"] longValue]];
    [self setQPB:[[metaData valueForKey:@"QPB"] longValue]];
    [self calcMSPQ];
    barManager = [[MKRBarManager alloc] initWithFeaturesIntervals:features andMSPQ:self.MSPQ andQPB:self.QPB];
    
    NSMutableArray<NSString *> *metaDataScenes = [metaData mutableArrayValueForKey:@"Scenes"];
    NSMutableArray<NSNumber *> *metaDataStructure = [metaData mutableArrayValueForKey:@"Structure"];
    NSInteger identifier = 0;
    for (NSString *metaDataScene in metaDataScenes) {
        MKRScene *scene;
        //TODO: refactor using scene factory
        if ([metaDataScene isEqualToString:@"SceneA"]) {
            scene = [[MKRSceneA alloc] initWithIdentifier:identifier++];
        } else if ([metaDataScene isEqualToString:@"SceneB"]) {
            scene = [[MKRSceneB alloc] initWithIdentifier:identifier++];
        } else {
            @throw ([NSException exceptionWithName:@"Unknown scene type" reason:@"Unknown scene type in track meta data" userInfo:nil]);
        }
        [scenes addObject:scene];
    }
    for (NSNumber *structureSceneIdentifier in metaDataStructure) {
        if ([scenes count] <= [structureSceneIdentifier longValue] || [structureSceneIdentifier longValue] < 0) {
            @throw ([NSException exceptionWithName:@"Unknown scene identifier" reason:@"Unknown scene identifier in track structure" userInfo:nil]);
        }
        [structure addObject:scenes[[structureSceneIdentifier longValue]]];
    }
    
    return self;
}

-(void)calcMSPQ {
    [self setMSPQ:(1000.0 * 60.0  / self.BPM / self.QPB)];
}

-(BOOL)fillScenes {
    for (MKRScene *scene in scenes) {
        if (![scene fillBarsWithBarManager:barManager]) {
            return NO;
        }
    }
    return YES;
}

@end
