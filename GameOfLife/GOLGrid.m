//
//  GOLGrid.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "GOLGrid.h"

@interface GOLGrid ()
@property (nonatomic, strong) NSArray *grid;
@end
@implementation GOLGrid

- (id)initWithSize:(NSUInteger)size
{
    return [self initWithSize:size cellBlock:nil];
}

- (id)initWithSize:(NSUInteger)size cellBlock:(GridInitBlock)initBlock
{
    self = [super init];
    if (!self) return nil;
    
    _size = size;
    NSMutableArray *grid = [[NSMutableArray alloc] initWithCapacity:size];
    for (int i = 0; i < size; i++) {
        NSMutableArray *a = [[NSMutableArray alloc] initWithCapacity:size];
        for (int j = 0; j < size; j++) {
            id object = nil;
            if (initBlock != nil) {
                object = initBlock(i,j);
            }
            if (object == nil) {
                object = [NSNull null];
            }
            [a addObject:object];
        }
        [grid addObject:[a copy]];
    }
    _grid = [grid copy];
    
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
    NSUInteger maxRow = MIN(row + 1, self.size - 1);
    
    NSUInteger minCol = MAX((NSInteger)col - 1, 0);
    NSUInteger maxCol = MIN(col + 1, self.size - 1);
    
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
