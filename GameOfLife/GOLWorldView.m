//
//  GOLWolrdView.m
//  GameOfLife
//
//  Created by Julien on 2/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "GOLWorldView.h"

@implementation GOLWorldView

//+ (Class)layerClass
//{
//    return [CATiledLayer class];
//}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    
    [self _commonInit];
    
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self _commonInit];
    
    return self;
}

- (void)_commonInit
{
//    CATiledLayer *tiledLayer = (CATiledLayer *)self.layer;
//    tiledLayer.levelsOfDetail = 2;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSUInteger columns = [self.dataSource numberOfColumnInWorldView:self];
    NSUInteger rows = [self.dataSource numberOfRowsInWorldView:self];
    CGFloat cellWidth = self.bounds.size.width / columns;
    CGFloat cellHeight = self.bounds.size.height / rows;
    
    NSUInteger minRow = floorf(rect.origin.y / cellHeight);
    NSUInteger maxRow = ceilf(CGRectGetMaxY(rect) / cellHeight);
    
    NSUInteger minCol = floorf(rect.origin.x / cellWidth);
    NSUInteger maxCol = ceilf(CGRectGetMaxX(rect) / cellWidth);
    
    for (NSUInteger row = minRow; row < maxRow; row++) {
        for (NSUInteger col = minCol; col < maxCol; col++) {
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
