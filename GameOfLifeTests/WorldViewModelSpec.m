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
#import "GOLWorldSeeder.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GOLWorldViewModel ()
@property (nonatomic, strong) GOLWorldRunner *runner;
@property (nonatomic, strong) GOLWorldSeeder *seeder;
@property (nonatomic, strong) GOLWorld *world;
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
    
    it(@"picks the correct row, column for a given index", ^{
        id mockWorld = mock([GOLWorld class]);
        vm.world = mockWorld;
        
        for(int i = 0; i < vm.rows; i++) {
            for(int j = 0; j < vm.columns; j++) {
                __unused CellState _ = [vm cellStateForRow:i column:j];
                [verify(mockWorld) cellAtRow:i col:j];
            }
        }
    });
    
    describe(@"Forward to Runner", ^{
        __block GOLWorldRunner *mockRunner;
        beforeEach(^{
            mockRunner = mock([GOLWorldRunner class]);
            vm.runner = mockRunner;
        });
        it(@"forwards -(RACSignal*)clock to runner", ^{
            __unused RACSignal *_ = vm.clock;
            [verify(mockRunner) clock];
        });
        
        it(@"forward `play` call to runner", ^{
            [vm play];
            [verify(mockRunner) play];
        });
        
        it(@"forward `pause` call to runner", ^{
            [vm pause];
            [verify(mockRunner) pause];
        });
        
        it(@"forward `stop` call to runner", ^{
            [vm stop];
            [verify(mockRunner) stop];
        });
    });
    
    it(@"binds running to runner.running", ^{
        [vm.runner pause];
        expect([vm isRunning]).to.beFalsy();
        [vm.runner play];
        expect(vm.running).to.beTruthy();
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
    
    describe(@"randomize world", ^{
        it(@"asks the seeder to generate a patter", ^{
            id mockSeeder = mock([GOLWorldSeeder class]);
            vm.seeder = mockSeeder;

            [vm randomize];
            [verify(mockSeeder) generatePattern];
           
        });
        
        it(@"seed the world", ^{
            id mockWorld = mock([GOLWorld class]);
            vm.world = mockWorld;
            
            [vm randomize];
            [verify(mockWorld) seed:anything()];
        });
    });
    
    describe(@"Button visibility", ^{
        it(@"has Play button title when the world is not running", ^{
            expect(vm.playPauseButtonTitle).to.equal(@"Play");
        });
        
        it(@"has Pause button title when the world is running", ^{
            [vm play];
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
