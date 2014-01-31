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

@interface GOLWorldViewModel ()
@property (nonatomic, strong) RACSignal *clock;
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
    
    
    describe(@"ticking", ^{
        beforeEach(^{
            vm.tickInterval = 0.2;
            vm.active = YES;
        });
        afterEach(^{
            vm.clock = nil;
        });
        
        it(@"tick the world on every clock tick", ^{
            [vm.clock subscribeNext:^(id x) {
            }];
            vm.running = YES;
            expect(vm.generationCount).will.equal(5);
        });

        it(@"changes the frequency with the tick interval", ^{
            vm.tickInterval = 0.1;
            NSTimeInterval timeout = 1.0;
            
            __block NSUInteger counter = 0;
            [vm.clock subscribeNext:^(id x) {
                counter++;
            }];
            vm.running = YES;
            [Expecta setAsynchronousTestTimeout:timeout];
            expect(counter).will.equal((timeout / vm.tickInterval));

        });
        
        it(@"stop if running is set to NO", ^{
            __block NSError *timeout = nil;
            __block NSUInteger counter = 0;
            [[vm.clock timeout:0.5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                vm.running = NO;
                counter++;
            } error:^(NSError *error) {
                timeout = error;
            }];
            vm.running = YES;
            
            expect(counter).will.equal(1);
            expect(timeout).willNot.beNil();
        });
    });
});

SpecEnd
