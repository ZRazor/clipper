//
//  APLCustomVideoCompositor.h
//  clipper
//
//  Created by Mikhail Zinov on 13.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MKRFiltersManager.h"

@interface MKRCustomVideoCompositor : NSObject <AVVideoCompositing>

@property (nonatomic) MKRFiltersManager *filtersManager;

@end;


