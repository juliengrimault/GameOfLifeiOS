//
//  GOLWolrdView.m
//  GameOfLife
//
//  Created by Julien on 2/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "GOLWorldView.h"

@implementation GOLWorldView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSUInteger columns = [self.dataSource numberOfColumnInWorldView:self];
    NSUInteger rows = [self.dataSource numberOfRowsInWorldView:self];
    CGFloat cellWidth = self.bounds.size.width / columns;
    CGFloat cellHeight = self.bounds.size.height / rows;
    
    for (NSUInteger row = 0; row < rows; row++) {
        for (NSUInteger col = 0; col < columns; col++) {
            CGRect cellRect = CGRectMake(col * cellWidth, row * cellHeight, cellWidth, cellHeight);
            UIColor *color = [self colorForCellState:[self.dataSource worldView:self cellStateForRow:row column:col]];
            
            CGContextSetFillColorWithColor(context, color.CGColor);
            CGContextFillRect(context, cellRect);
        }
    }
    
}

- (UIColor *)colorForCellState:(CellState)state
{
    return state == CellStateAlive ? [UIColor blackColor] : [UIColor whiteColor];
}


@end
