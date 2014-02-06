//
//  GridSpec.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright 2014 julien. All rights reserved.
//

#define EXP_SHORTHAND

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "GOLGrid.h"


SpecBegin(GOLGrid)

describe(@"Grid", ^{
    __block GOLGrid *grid;
    __block CGSize size;
    beforeEach(^{
        size = CGSizeMake(5, 10);
        grid = [[GOLGrid alloc] initWithSize:size];
    });
    
    it(@"has a size", ^{
        expect(grid.rows).to.equal(size.height);
        expect(grid.columns).to.equal(size.width);
    });
    
    it(@"can access a cell", ^{
        id cell = [grid cellAtRow:0 col:0];
        expect(cell).to.beNil;
        
        cell = [grid cellAtRow:size.height - 1 col:size.width - 1];
        expect(cell).to.beNil;
    });
    
    it(@"raises if accessing outside of the boundary", ^{
        expect(^{
            [grid cellAtRow:-1 col:0];
        }).to.raise(@"NSRangeException");
    });
    
    it(@"initializes the cell with the given block", ^{
        __block NSUInteger counter = 0;
        grid = [[GOLGrid alloc] initWithSize:size cellBlock:^id(NSUInteger row, NSUInteger col) {
            counter++;
            return [NSNull null];
        }];
        expect(grid).notTo.beNil;
        expect(counter).to.equal(size.width * size.height);
    });
    
    describe(@"Neighbours", ^{
        it(@"returns the 8 adjacent cells for normal case", ^{
            NSArray *adjacents = [grid neighboursAtRow:2 col:2];
            NSArray *expected = @[
                                  [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                  [NSValue valueWithCGPoint:CGPointMake(1, 2)],
                                  [NSValue valueWithCGPoint:CGPointMake(1, 3)],
                                  [NSValue valueWithCGPoint:CGPointMake(2, 1)],
                                  [NSValue valueWithCGPoint:CGPointMake(2, 3)],
                                  [NSValue valueWithCGPoint:CGPointMake(3, 1)],
                                  [NSValue valueWithCGPoint:CGPointMake(3, 2)],
                                  [NSValue valueWithCGPoint:CGPointMake(3, 3)]];
            
            expect(adjacents.count).to.equal(expected.count);
            for (NSValue *v in expected) {
                expect([adjacents containsObject:v]).to.equal(YES);
            }
        });
        
        it(@"returns the 3 cells for (0,0)", ^{
            NSArray *adjacents = [grid neighboursAtRow:0 col:0];
            NSArray *expected = @[
                                  [NSValue valueWithCGPoint:CGPointMake(0, 1)],
                                  [NSValue valueWithCGPoint:CGPointMake(1, 1)],
                                  [NSValue valueWithCGPoint:CGPointMake(1, 0)]];
            
            expect(adjacents.count).to.equal(expected.count);
            for (NSValue *v in expected) {
                expect([adjacents containsObject:v]).to.equal(YES);
            }
        });
        
        it(@"returns the 3 cells for (rows-1, column-1)", ^{
            NSArray *adjacents = [grid neighboursAtRow:9 col:4];
            NSArray *expected = @[
                                  [NSValue valueWithCGPoint:CGPointMake(8, 3)],
                                  [NSValue valueWithCGPoint:CGPointMake(8, 4)],
                                  [NSValue valueWithCGPoint:CGPointMake(9, 3)]];
            
            expect(adjacents.count).to.equal(expected.count);
            for (NSValue *v in expected) {
                expect([adjacents containsObject:v]).to.equal(YES);
            }
        });
        
    });

});

SpecEnd
