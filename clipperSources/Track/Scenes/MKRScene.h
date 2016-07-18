//
//  MKRScene.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

/*!
 @class MKRScene
 @abstract representation of track's scene. Renders all of the bars one by one
*/

#import <Foundation/Foundation.h>
#import "MKRBarManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MKRAutomationLane.h"

@interface MKRScene : NSObject

@property(nonatomic) NSMutableArray<MKRBar *> *bars;
@property(readonly, nonatomic) NSInteger identifier;

- (instancetype)initWithIdentifier:(NSInteger)identifier;

- (MKRAutomationLane *)automationFor:(NSInteger)audioUnitIdentifier andParameter:(AudioUnitParameterID)parameter in:(NSMutableArray<MKRAutomationLane *> *)automations;

- (BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager;

/*!
  @abstract this method appends part of the composition to result and shifts resultCursorPtr
*/
- (void)makeComposition:(AVMutableComposition *)composition withBarAssets:(NSMutableDictionary *)barsAssets andResultCursorPtr:(CMTime *)resultCursorPtr andMSPQ:(double)MSPQ andAutomations:(NSMutableArray<MKRAutomationLane *> *)automations;

- (void)makeCompositionBar:(AVMutableComposition *)composition withBarAsset:(AVMutableComposition *)barAsset andWithBar:(MKRBar *)bar andWithResultCursorPtr:(CMTime *)resultCursorPtr andWithMSPQ:(double)MSPQ andWithBarRange:(CMTimeRange)barTimeRange usingAutoComplete:(BOOL)autoComplete;

- (void)insertTimeRange:(AVMutableComposition *)composition ofAsset:(AVAsset *)asset startAt:(CMTime)startAt duration:(CMTime)duration resultCursorPtr:(CMTime *)resultCursorPtr;

- (void)insertEmptyInComposition:(AVMutableComposition *)composition startAt:(CMTime)startAt duration:(CMTime)duration;

@end