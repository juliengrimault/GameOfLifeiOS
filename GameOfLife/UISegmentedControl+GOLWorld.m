//
//  UISegmentedControl+GOLWorld.m
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "UISegmentedControl+GOLWorld.h"

@implementation UISegmentedControl (GOLWorld)

+ (NSTimeInterval)tickIntervalForIndex:(NSUInteger)index
{
    switch (index) {
        case 2: // fast
            return 0.1;
            
        case 1: // Normal
            return 0.5;
            
        case 0: // slow
        default:
            return 1.0;
    }
}

+ (NSUInteger)indexForTickInterval:(NSTimeInterval)tick
{
    if (tick == 0.1) {
        return 2;
    } else if (tick == 0.5) {
        return 1;
    } else if (tick == 1.0) {
        return 0;
    } else {
        [NSException raise:@"InvalidTickInterval" format:@"tick %.2f is not one of the accepted values: 0.1, 0.5, 1.0", tick];
    }
    return 0;
}
@end
