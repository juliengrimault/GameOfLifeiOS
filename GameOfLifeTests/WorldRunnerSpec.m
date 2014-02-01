//
//  WorldRunnerSpec.m
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright 2014 julien. All rights reserved.
//

#define EXP_SHORTHAND

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GOLWorld.h"
#import "GOLWorldRunner.h"

SpecBegin(GOLWorldRunner)

describe(@"WorldRunner", ^{
    __block GOLWorld *world = [[GOLWorld alloc] initWithSize:2];
    __block GOLWorldRunner *runner = [[GOLWorldRunner alloc] initWithWorld:world];
    
    describe(@"ticking", ^{
        beforeEach(^{
            runner.tickInterval = 0.2;
        });
        
        it(@"tick the world on every clock tick", ^{
            [runner.clock subscribeNext:^(id x) {
            }];
            runner.running = YES;
            expect(world.generationCount).will.equal(5);
        });
        
        it(@"changes the frequency with the tick interval", ^{
            runner.tickInterval = 0.1;
            NSTimeInterval timeout = 1.0;
            
            __block NSUInteger counter = 0;
            [runner.clock subscribeNext:^(id x) {
                counter++;
            }];
            runner.running = YES;
            [Expecta setAsynchronousTestTimeout:timeout];
            expect(counter).will.equal((timeout / runner.tickInterval));
            
        });
        
        it(@"stop if running is set to NO", ^{
            __block NSError *timeout = nil;
            __block NSUInteger counter = 0;
            [[runner.clock timeout:0.5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                runner.running = NO;
                counter++;
            } error:^(NSError *error) {
                timeout = error;
            }];
            runner.running = YES;
            
            expect(counter).will.equal(1);
            expect(timeout).willNot.beNil();
        });
    });

});

SpecEnd
