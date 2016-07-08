//
//  MKRBarManager.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRTrack.h"
#import "MKRInterval.h"
#import "MKRBar.h"

@interface MKRBarManager : NSObject

@property (nonatomic) MKRTrack *track;
@property (nonatomic) NSMutableArray<MKRInterval *> *features;

-(instancetype)initWithTrack:(MKRTrack *)track andFeaturesIntervals:(NSMutableArray<MKRInterval *> *)features;
-(NSMutableArray<MKRBar *> *)getBarsWithQuantsLength:(NSNumber *)quantsLength;

@end
