//
//  UISegmentedControl+GOLWorld.h
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISegmentedControl (GOLWorld)

+ (NSTimeInterval)tickIntervalForIndex:(NSUInteger)index;
+ (NSUInteger)indexForTickInterval:(NSTimeInterval)tick;
@end
