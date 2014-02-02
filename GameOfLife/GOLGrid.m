//
//  GOLGrid.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "GOLGrid.h"

@interface GOLGrid ()
@property (nonatomic, copy) NSArray *grid;
@property (nonatomic) NSUInteger rows;
@property (nonatomic) NSUInteger columns;
@end
@implementation GOLGrid

- (id)initWithSize:(CGSize)size
{
    return [self initWithSize:size cellBlock:nil];
}

- (id)initWithSize:(CGSize)size cellBlock:(GridInitBlock)initBlock
{
    self = [super init];
    if (!self) return nil;
    
    self.columns = size.width;
    self.rows = size.height;
    
    NSMutableArray *grid = [NSMutableArray array];
    for (int row = 0; row < self.rows; row++) {
        NSMutableArray *a = [NSMutableArray array];
        for (int col = 0; col < self.columns; col++) {
            id object = nil;
            if (initBlock != nil) {
                object = initBlock(row,col);
            }
            if (object == nil) {
                object = [NSNull null];
            }
            [a addObject:object];
        }
        [grid addObject:[a copy]];
    }
    self.grid = grid;
    
    return self;
}

- (id)cellAtRow:(NSUInteger)row col:(NSUInteger)col
{
    return self.grid[row][col];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return self.grid[idx];
}

- (NSArray *)neighboursAtRow:(NSUInteger)row col:(NSUInteger)col
{
    NSUInteger minRow = MAX((NSInteger)row - 1, 0);
    NSUInteger maxRow = MIN(row + 1, self.rows - 1);
    
    NSUInteger minCol = MAX((NSInteger)col - 1, 0);
    NSUInteger maxCol = MIN(col + 1, self.columns - 1);
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:8];
    for (NSUInteger i = minRow; i <= maxRow; i++) {
        for (NSUInteger j = minCol; j <= maxCol; j++) {
            if (i == row && j == col)
                continue;
            
            [values addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
        }
    }
    return values;
}

- (void)enumerateCells:(GridEnumerateBlock)block
{
    NSUInteger i = 0;
    for (NSArray *row in self.grid) {
        NSUInteger j = 0;
        for (id object in row) {
            if (block != nil)
                block(i, j, object);
            j++;
        }
        i++;
    }
}

@end
