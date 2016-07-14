//
//  UIColor+MKRColor.m
//  echeep
//
//  Created by Mikhail Zinov on 15.02.16.
//  Copyright © 2016 MAYAK RED. All rights reserved.
//

#import "UIColor+MKRColor.h"

@implementation UIColor (MKRColor)


+ (UIColor *)mkr_mainColor {
    return [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1];
}

+ (UIColor *)mkr_lightGrayColor {
    return [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
}

+ (UIColor *)mkr_darkGrayColor {
    return [UIColor colorWithRed:180.f/255.f green:180.f/255.f blue:180.f/255.f alpha:1];
}

+ (UIColor *)mkr_redColor {
    return [UIColor colorWithRed:219.f/255.f green:49.f/255.f blue:49.f/255.f alpha:1];
}

+ (UIColor *)mkr_darkRedColor {
    return [UIColor colorWithRed:147.f/255.f green:12.f/255.f blue:12.f/255.f alpha:1];
}

@end
