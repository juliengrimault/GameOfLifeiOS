//
//  WorldSpeedSpec.m
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright 2014 julien. All rights reserved.
//

#define EXP_SHORTHAND

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import "UISegmentedControl+GOLWorld.h"

SpecBegin(UISegmentedControl_WorldSpeed)

describe(@"UISegmentedControl", ^{
    it(@"maps index 0 to interval 1", ^{
        expect([UISegmentedControl tickIntervalForIndex:0]).to.equal(1);
    });
    
    it(@"maps index 1 to interval  0.5", ^{
        expect([UISegmentedControl tickIntervalForIndex:1]).to.equal(0.5);
    });
    
    it(@"maps index 2 to interval  0.1", ^{
        expect([UISegmentedControl tickIntervalForIndex:2]).to.equal(0.1);
    });
    
    it(@"defaults to speed 1", ^{
        expect([UISegmentedControl tickIntervalForIndex:4]).to.equal(1);
    });
    
    
    it(@"maps interval 0.1 to segment 2", ^{
        expect([UISegmentedControl indexForTickInterval:0.1]).to.equal(2);
    });
    
    it(@"maps interval 0.5 to segment 1", ^{
        expect([UISegmentedControl indexForTickInterval:0.5]).to.equal(1);
    });
    
    it(@"maps interval 1 to segment 0", ^{
        expect([UISegmentedControl indexForTickInterval:1]).to.equal(0);
    });
    
    it(@"raises an error if speed is not an 'accepted' value", ^{
        expect(^{
            [UISegmentedControl indexForTickInterval:0.7];
        }).to.raiseAny();
    });
});

SpecEnd
