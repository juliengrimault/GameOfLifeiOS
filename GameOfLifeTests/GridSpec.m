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
    NSUInteger size = 5;
    beforeEach(^{
        grid = [[GOLGrid alloc] initWithSize:size];
    });
    
    it(@"has a size", ^{
        expect(grid.size).to.equal(5);
    });
    
    it(@"can access a cell", ^{
        id cell = [grid cellAtRow:0 col:0];
        expect(cell).to.beNil;
    });
    
    it(@"raises if accessing outside of the boundary", ^{
        expect(^{
            [grid cellAtRow:-1 col:0];
        }).to.raise(@"NSRangeException");
    });
    
    it(@"initializes the cell with the given block", ^{
        __block NSUInteger counter = 0;
        GOLGrid *grid = [[GOLGrid alloc] initWithSize:size cellBlock:^id(NSUInteger row, NSUInteger col) {
            counter++;
            return [NSNull null];
        }];
        expect(grid).notTo.beNil;
        expect(counter).to.equal(size * size);
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
        
        it(@"returns the 3 cells for (size-1, size-1)", ^{
            NSArray *adjacents = [grid neighboursAtRow:4 col:4];
            NSArray *expected = @[
                                  [NSValue valueWithCGPoint:CGPointMake(3, 3)],
                                  [NSValue valueWithCGPoint:CGPointMake(3, 4)],
                                  [NSValue valueWithCGPoint:CGPointMake(4, 3)]];
            
            expect(adjacents.count).to.equal(expected.count);
            for (NSValue *v in expected) {
                expect([adjacents containsObject:v]).to.equal(YES);
            }
        });
        
    });

});

SpecEnd
