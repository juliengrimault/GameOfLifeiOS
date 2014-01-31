//
//  RuleSpec.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright 2014 julien. All rights reserved.
//


#define EXP_SHORTHAND

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "GOLRule.h"


SpecBegin(GOLRule)

describe(@"Rule", ^{
    __block GOLRule *rule;
    beforeEach(^{
        rule = [[GOLRule alloc] init];
    });
    
    describe(@"alive cell", ^{
        it(@"toggles a cell if less than 2 neighbours", ^{
            BOOL shouldToggle = [rule shouldToggle:YES liveNeigboursCount:1];
            expect(shouldToggle).to.equal(YES);
        });
        
        it(@"toggles a cell if more than 3 neighbours", ^{

            BOOL shouldToggle = [rule shouldToggle:YES liveNeigboursCount:4];
            expect(shouldToggle).to.equal(YES);
        });
        
        it(@"does not toggle if live neighbour count is 2 or 3", ^{
            BOOL shouldToggleFor2 = [rule shouldToggle:YES liveNeigboursCount:2];
            expect(shouldToggleFor2).to.equal(NO);
            
            BOOL shouldToggleFor3 = [rule shouldToggle:YES liveNeigboursCount:3];
            expect(shouldToggleFor3).to.equal(NO);
        });
    });
    
    describe(@"dead cell", ^{
        it(@"toggles it if it has 3 live neigbours exactly", ^{
            for (int i = 0; i < 9; i++) {
                BOOL expectedToggle = i == 3;
                BOOL shouldToggle = [rule shouldToggle:NO liveNeigboursCount:i];
                expect(shouldToggle).to.equal(expectedToggle);
            }
        });
    });
});

SpecEnd
