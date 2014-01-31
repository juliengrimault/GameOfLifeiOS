//
//  GOLRule.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "GOLRule.h"

@implementation GOLRule

- (BOOL)shouldToggle:(BOOL)isAlive liveNeigboursCount:(NSUInteger)liveNeighboursCount
{
    if (isAlive) {
        if (liveNeighboursCount < 2 || liveNeighboursCount > 3)
            return YES;
        else
            return NO;
    } else {
        if (liveNeighboursCount == 3)
            return YES;
        else
            return NO;
    }
}

@end
