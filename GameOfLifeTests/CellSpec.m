//
//  CellSpec.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright 2014 julien. All rights reserved.
//

#define EXP_SHORTHAND

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "GOLCell.h"


SpecBegin(GOLCell)

describe(@"Cell", ^{
    __block GOLCell *cell;
    beforeEach(^{
        cell = [GOLCell new];
    });
    
    it(@"is dead by default", ^{
        expect(cell.alive).to.equal(NO);
    });
    
    it(@"can be brought to life", ^{
        [cell live];
        expect(cell.alive).to.equal(YES);
    });
    
    it(@"can be killed", ^{
        [cell live];
        [cell die];
        expect(cell.alive).to.equal(NO);
    });
    
    
});

SpecEnd
