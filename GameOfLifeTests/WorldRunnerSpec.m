//
//  WorldRunnerSpec.m
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright 2014 julien. All rights reserved.
//

#define EXP_SHORTHAND
#define HC_SHORTHAND
#define MOCKITO_SHORTHAND
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCHamcrest/OCHamcrest.h>
#import <OCMockito/OCMockito.h>

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GOLWorld.h"
#import "GOLWorldRunner.h"
#import "GOLCell.h"

@interface GOLWorldRunner()
@property (nonatomic, strong) GOLWorld *world;
@end

SpecBegin(GOLWorldRunner)

describe(@"WorldRunner", ^{
    NSString *seedPattern = @"*.\n"
                            @"..";
    __block GOLWorld *world;
    __block GOLWorldRunner *runner;
    
    beforeEach(^{
        world = [[GOLWorld alloc] initWithSize:CGSizeMake(2,2)];
        [world seed:seedPattern];
        runner = [[GOLWorldRunner alloc] initWithWorld:world];
    });
    
    it(@"sets running to YES when calling play", ^{
        [runner play];
        expect([runner isRunning]).to.beTruthy();
    });
    
    it(@"sets running to NO when calling pause", ^{
        [runner pause];
        expect([runner isRunning]).to.beFalsy();
    });
    
    describe(@"Stop",^{
        it(@"flips running to false", ^{
            [runner play];
            [runner stop];
            expect([runner isRunning]).to.beFalsy();

        });
        
        it(@"reset the world to its last seed", ^{
            GOLWorld *mockWorld = mock([GOLWorld class]);
            runner.world = mockWorld;
            [runner play];
            [runner stop];
            [verify(mockWorld) reset];
        });
    });
    
    
    describe(@"ticking", ^{
        beforeEach(^{
            runner.tickInterval = 0.2;
        });
        
        it(@"tick the world on every clock tick", ^{
            [runner.clock subscribeNext:^(id x) {
            }];
            [runner play];
            expect(world.generationCount).will.equal(5);
        });
        
        it(@"changes the frequency with the tick interval", ^{
            runner.tickInterval = 0.1;
            NSTimeInterval timeout = 1.0;
            
            __block NSUInteger counter = 0;
            [runner.clock subscribeNext:^(id x) {
                counter++;
            }];
            [runner play];
            [Expecta setAsynchronousTestTimeout:timeout];
            expect(counter).will.equal((timeout / runner.tickInterval));
            
        });
        
        it(@"stop if running is set to NO", ^{
            __block NSError *timeout = nil;
            __block NSUInteger counter = 0;
            [[runner.clock timeout:0.5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
                [runner pause];
                counter++;
            } error:^(NSError *error) {
                timeout = error;
            }];
            [runner play];
            
            expect(counter).will.equal(1);
            expect(timeout).willNot.beNil();
        });
    });

});

SpecEnd
