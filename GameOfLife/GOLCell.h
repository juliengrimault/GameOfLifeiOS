//
//  GOLCell.h
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOLCell : NSObject

@property (nonatomic, readonly, getter = isAlive) BOOL alive;

- (void)live;
- (void)die;
@end
