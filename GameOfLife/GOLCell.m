//
//  GOLCell.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "GOLCell.h"

@interface GOLCell ()
@property (nonatomic, getter = isAlive) BOOL alive;
@end

@implementation GOLCell

- (void)live
{
    self.alive = YES;
}

- (void)die
{
    self.alive = NO;
}
@end
