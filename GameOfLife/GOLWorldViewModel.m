//
//  GOLWorldViewModel.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GOLWorldViewModel.h"
#import "GOLWorld.h"
#import "GOLCell.h"
#import "GOLWorldRunner.h"
#import "GOLWorldSeeder.h"


@interface GOLWorldViewModel ()
@property (nonatomic, strong) GOLWorldRunner *runner;
@property (nonatomic, strong) GOLWorld *world;
@property (nonatomic, strong) GOLWorldSeeder *seeder;
@end

@implementation GOLWorldViewModel

- (id)initWithWorld:(GOLWorld *)world
{
    self = [super init];
    if (!self) return nil;
    
    self.world = world;
    self.runner = [[GOLWorldRunner alloc] initWithWorld:self.world];
    self.seeder = [[GOLWorldSeeder alloc] initWithSize:CGSizeMake(self.world.columns, self.world.rows)];
    
    RACSignal *generationCount = RACObserve(self.world, generationCount);
    RAC(self, generationCount) = generationCount;
    RAC(self, rows) = RACObserve(self.world, rows);
    RAC(self, columns) = RACObserve(self.world, columns);
    
    // 2 way bindings between the runner tickInterval and this tickInterval,
    // we need the 2 ways binding because tickInterval is not readonly.
    RACChannelTo(self,tickInterval) = RACChannelTo(self.runner, tickInterval);
    
    RAC(self, running) = RACObserve(self.runner, running);
    
    RACSignal *startedSignal = [generationCount map:^id(NSNumber *generation) {
        return @([generation integerValue] > 0);
    }];
    
    RAC(self, stopButtonHidden) = [startedSignal not];
    RAC(self, randomizeButtonHidden) = startedSignal;
    
    RACSignal *runningSignal = RACObserve(self, running);
    RAC(self, playButtonHidden) = runningSignal;
    RAC(self, pauseButtonHidden) = [runningSignal not];

    return self;
}

#pragma mark - GOLWorldRunner proxy
- (RACSignal *)clock
{
    return self.runner.clock;
}

- (void)play
{
    [self.runner play];
}

- (void)pause
{
    [self.runner pause];
}

- (void)stop
{
    [self.runner stop];
}

- (void)randomize
{
    NSString *pattern = [self.seeder generatePattern];
    [self.world seed:pattern];
}


- (CellState)cellStateForRow:(NSUInteger)row column:(NSUInteger)column
{
    GOLCell *cell = [self.world cellAtRow:row col:column];
    if ([cell isAlive]) {
        return CellStateAlive;
    } else {
        return CellStateDead;
    }
}

@end
