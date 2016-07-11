//
//  MKRScene.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRBarManager.h"
#import <AVFoundation/AVFoundation.h>

@interface MKRScene : NSObject

@property(nonatomic) NSMutableArray<MKRBar *> *bars;
@property(readonly, nonatomic) NSInteger identifier;

-(instancetype)initWithIdentifier:(NSInteger)identifier;

-(BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager;

-(void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(NSInteger)MSPQ;
-(void)makeCompositionBar:(AVMutableComposition *)composition withBarAsset:(AVMutableComposition *)barAsset andWithBar:(MKRBar *)bar andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(NSInteger)MSPQ andWithBarRange:(CMTimeRange)barTimeRange usingAutoComplete:(BOOL)autoComplete;

-(void)insertTimeRange:(AVMutableComposition *)composition ofAsset:(AVAsset *)asset startAt:(CMTime)startAt duration:(CMTime)duration resultCursorPtr:(CMTime *)resultCursorPtr;

@end