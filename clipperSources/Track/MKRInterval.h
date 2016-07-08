//
//  MKRInterval.h
//  clipper
//
//  Created by dev on 08.07.16.
//  Copyright © 2016 mayak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKRInterval : NSObject

@property (readonly, nonatomic) NSInteger start;
@property (readonly, nonatomic) NSInteger end;

/*!
 @abstract
    Returns length of the interval in milliseconds
 */
- (NSInteger)length;

- (id)initWithStart:(int)start andEnd:(int)end;

@end
