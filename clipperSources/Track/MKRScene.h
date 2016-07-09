//
//  MKRScene.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRBarManager.h"

@interface MKRScene : NSObject

@property(nonatomic) NSMutableArray *bars;
@property(readonly, nonatomic) NSInteger identifier;

-(instancetype)initWithIdentifier:(NSInteger)identifier;
-(BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager;

@end