//
//  GOLWorld.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "GOLWorld.h"
#import "GOLGrid.h"
#import "GOLCell.h"
#import "GOLRule.h"

@interface GOLWorld()
@property (nonatomic) NSUInteger rows;
@property (nonatomic) NSUInteger columns;

@property (nonatomic) NSUInteger generationCount;
@property (nonatomic, copy) NSString *initialMap;

@property (nonatomic, strong) GOLGrid *grid;
@property (nonatomic, strong) GOLRule *rule;
@end

@implementation GOLWorld

- (id)initWithSize:(CGSize)size
{
    self = [super init];
    if (!self) return nil;
    
    self.rows = size.height;
    self.columns = size.width;
    self.generationCount = 0;
    self.grid = [[GOLGrid alloc] initWithSize:size
                                cellBlock:^id(NSUInteger row, NSUInteger column) {
                                    return [GOLCell new];
                                }];
    _rule = [[GOLRule alloc] init];
    _initialMap = [self asciiDescription];
    
    return self;
}

- (GOLCell *)cellAtRow:(NSUInteger)row col:(NSUInteger)col
{
    return self.grid[row][col];
}

- (void)reset
{
    [self seed:self.initialMap];
}

- (void)seed:(NSString *)pattern
{
    self.generationCount = 0;
    NSUInteger row = 0;
    for (NSString *line in [pattern componentsSeparatedByString:@"\n"]) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        for (NSUInteger i = 0; i < trimmed.length; i++) {
            unichar c = [trimmed characterAtIndex:i];
            GOLCell *cell = [self cellAtRow:row col:i];
            if (c == '*') {
                [cell live];
            } else {
                [cell die];
            }
        }
        row++;
    };
    self.initialMap = [self asciiDescription];
}

- (NSString *)asciiDescription
{
    NSMutableString *desc = [NSMutableString new];
    for (int i = 0; i < self.grid.rows; i++) {
        for (int j = 0; j < self.grid.columns; j++) {
            GOLCell *cell = [self cellAtRow:i col:j];
            if ([cell isAlive])
                [desc appendString:@"*"];
            else
                [desc appendString:@"."];
        }
        if (i < self.grid.rows - 1)
            [desc appendString:@"\n"];
    }
    return [desc copy];
}

- (void)tick
{
    self.generationCount += 1;
    NSMutableArray *toToggle = [NSMutableArray new];
    
    [self.grid enumerateCells:^(NSUInteger row, NSUInteger column, GOLCell *cell) {
        
        if ([self shouldToggleCell:cell atRow:row column:column]) {
            [toToggle addObject:cell];
        }
    }];
    
    [self toggleCells:toToggle];
}

- (BOOL)shouldToggleCell:(GOLCell *)cell atRow:(NSUInteger)row column:(NSUInteger)column
{
    NSUInteger liveNeighboursCount = [self liveNeighboursForCellAtRow:row column:column];
    
    return [self.rule shouldToggle:cell.alive liveNeigboursCount:liveNeighboursCount];
}

- (NSUInteger)liveNeighboursForCellAtRow:(NSUInteger)row column:(NSUInteger)column
{
    NSUInteger count = 0;
    NSArray *neighbours = [self.grid neighboursAtRow:row col:column];
    
    for (NSValue *neighbour in neighbours) {
        CGPoint coordinate = [neighbour CGPointValue];
        GOLCell *cell = [self cellAtRow:coordinate.x col:coordinate.y];
        
        if ([cell isAlive])
            count += 1;
    }
    return count;
}


- (void)toggleCells:(NSArray *)cells
{
    for(GOLCell *cell in cells) {
        if ([cell isAlive])
            [cell die];
        else
            [cell live];
    }
}


@end
