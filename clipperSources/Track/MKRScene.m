//
//  MKRScene.m
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import "MKRScene.h"

@interface MKRScene()

@property (readwrite, nonatomic) NSInteger identifier;

@end

@implementation MKRScene

-(instancetype)initWithIdentifier:(NSInteger)identifier {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setBars:[NSMutableArray<MKRBar *> new]];
    [self setIdentifier:identifier];
    
    return self;
}

-(BOOL)fillBarsWithBarManager:(MKRBarManager *)barManager {
    @throw([NSException exceptionWithName:NSInternalInconsistencyException reason:@"You must override this method in subclass" userInfo:nil]);
}

@end
