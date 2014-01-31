//
//  WorldViewModelSpec.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright 2014 julien. All rights reserved.
//
#define EXP_SHORTHAND
#define HC_SHORTHAND
#define MOCKITO_SHORTHAND
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

#import "GOLWorldViewModel.h"
#import "GOLWorld.h"
#import "GOLCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

SpecBegin(GOLWorldViewModel)

describe(@"WorldViewModel", ^{
    __block GOLWorld *world;
    __block GOLWorldViewModel *vm;
    
    beforeEach(^{
        world = [[GOLWorld alloc] initWithSize:2];
        [world seed:
         @".*\n"
         @"*."];
        vm = [[GOLWorldViewModel alloc] initWithWorld:world];
    });
    
    it(@"binds the generation to the world's generationCount", ^{
        [world tick];
        expect(vm.generationCount).to.equal(world.generationCount);
    });
    
    it(@"has the world number of columns and rows", ^{
        expect(vm.columns).to.equal(world.size);
        expect(vm.rows).to.equal(world.size);
    });
    
    it(@"has the number of items to display", ^{
        expect(vm.numberOfItems).to.equal(world.size * world.size);
    });
    
    it(@"picks the correct row, column for a given index", ^{
        expect(vm.numberOfItems).to.equal(world.size * world.size);
        for(int i = 0; i < vm.numberOfItems; i++) {
            GOLCell *c = [world cellAtRow:(i / vm.columns) col:(i % vm.columns)];
            expect([vm cellStateForItemAtIndex:i]).to.equal((CellState)[c isAlive]);
        }

    });
    
    
    describe(@"ticking", ^{
        __block GOLWorld *mock;
        beforeEach(^{
            mock = mock([GOLWorld class]);
            vm = [[GOLWorldViewModel alloc] initWithWorld:mock];
            vm.tickInterval = 0.1;
        });
        
        it(@"regularly", ^{
            __block NSUInteger counter = 0;
            [vm.clock doNext:^(id x) {
                counter++;
            }];
            vm.active = YES;
            [Expecta setAsynchronousTestTimeout:2];
            expect(counter).will.beGreaterThanOrEqualTo(1);
        });
        
        it(@"tick the world on every clock tick", ^{
            [vm.clock subscribeNext:^(id x) {
            }];
            expect(vm.generationCount).will.beGreaterThanOrEqualTo(1);
            vm.active = YES;

        });
    });
});

SpecEnd
