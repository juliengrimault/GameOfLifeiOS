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
#import "GOLWorldRunner.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GOLWorldViewModel ()
@property (nonatomic, strong) GOLWorldRunner *runner;
@end

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
    
    describe(@"Forward to Runner", ^{
        __block GOLWorldRunner *mockRunner;
        beforeEach(^{
            mockRunner = mock([GOLWorldRunner class]);
            vm.runner = mockRunner;
        });
        it(@"forwards -(RACSignal*)clock to runner", ^{
            RACSignal *_ = vm.clock;
            [verify(mockRunner) clock];
        });
        
        it(@"forwards isRunning call to runner", ^{
            BOOL _ = [vm isRunning];
            [verify(mockRunner) isRunning];
        });
        
        it(@"forwards isRunning call to runner", ^{
            vm.running = YES;
            [verify(mockRunner) setRunning:YES];
        });
    });
    
    it(@"binds tickInterval to runner.tickInterval", ^{
        expect(vm.tickInterval).to.equal(vm.runner.tickInterval);
    });
    
    it(@"forwards setTickInterval call to runner", ^{
        vm.tickInterval = 10;
        expect(vm.runner.tickInterval).equal(10);
        vm.runner.tickInterval = 5;
        expect(vm.tickInterval).equal(5);
    });
    

    
    describe(@"Button visibility", ^{
        it(@"has Play button title when the world is not running", ^{
            vm.running = NO;
            expect(vm.playPauseButtonTitle).to.equal(@"Play");
        });
        
        it(@"has Pause button title when the world is running", ^{
            vm.running = YES;
            expect(vm.playPauseButtonTitle).to.equal(@"Pause");
        });
        
        it(@"shows the Stop button when simulation is started", ^{
            [world tick];
            expect(vm.stopButtonHidden).to.equal(NO);
        });
        
        it(@"hides the Stop button when simulation is not started", ^{
            expect(vm.stopButtonHidden).to.equal(YES);
        });
        
        it(@"shows the randomize button when the simulation is not started", ^{
            expect(vm.randomizeButtonHidden).to.equal(NO);
        });
        
        it(@"hides the randomize button when the simulation is started", ^{
            [world tick];
            expect(vm.randomizeButtonHidden).to.equal(YES);
        });
    });
});

SpecEnd
