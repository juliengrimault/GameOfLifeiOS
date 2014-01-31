//
//  GOLWorld.h
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GOLCell;

typedef enum CellState {
    CellStateDead,
    CellStateAlive
} CellState;

@interface GOLWorld : NSObject

@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, readonly) NSUInteger generationCount;

- (id)initWithSize:(NSUInteger)size;

- (GOLCell *)cellAtRow:(NSUInteger)row col:(NSUInteger)col;

- (void)seed:(NSString *)pattern;

- (NSString *)asciiDescription;

- (void)tick;
@end
