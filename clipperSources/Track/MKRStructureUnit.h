//
// Created by Anton Zlotnikov on 15.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKRScene;


@interface MKRStructureUnit : NSObject

- (instancetype)initWithScene:(MKRScene *)aScene;

- (MKRScene *)getScene;

- (void)setTimeIntervalWithStartTime:(Float64)start andEndTime:(Float64)end;

- (Float64)getStartTime;

- (Float64)getEndTime;
@end