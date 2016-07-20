//
// Created by Anton Zlotnikov on 18.07.16.
// Copyright (c) 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MKRTrackManager : NSObject


- (NSInteger)tracksCount;

- (NSString *)trackNameForRow:(NSInteger)row;

- (NSString *)pathForMetaDesc:(NSString *)trackName;

- (NSString *)pathForPlayback:(NSString *)trackName;
@end