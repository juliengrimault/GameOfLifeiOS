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
    
    _world = world;
    _runner = [[GOLWorldRunner alloc] initWithWorld:world];
    _seeder = [[GOLWorldSeeder alloc] initWithSize:world.size];
    
    RACSignal *generationCount = RACObserve(self.world, generationCount);
    RAC(self, generationCount) = generationCount;
    RAC(self, rows) = RACObserve(self.world, size);
    RAC(self, columns) = RACObserve(self.world, size);
    
    // 2 way bindings between the runner tickInterval and this tickInterval,
    // we need the 2 ways binding because tickInterval is not readonly.
    RACChannelTo(self,tickInterval) = RACChannelTo(self.runner, tickInterval);
    
    RAC(self, running) = RACObserve(self.runner, running);
    
    RACSignal *startedSignal = [generationCount map:^id(NSNumber *generation) {
        return @([generation integerValue] > 0);
    }];
    
    RAC(self, stopButtonHidden) = [startedSignal not];
    RAC(self, randomizeButtonHidden) = startedSignal;
    
    RAC(self, playPauseButtonTitle) = [RACObserve(self, running) map:^id(NSNumber *x) {
        if ([x boolValue]) {
            return NSLocalizedString(@"Pause", nil);
        } else {
            return NSLocalizedString(@"Play", nil);
        }
    }];

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

#pragma mark - UICollectionViewDataSource

- (NSUInteger)numberOfItems
{
    return self.rows * self.columns;
    
}
- (CellState)cellStateForItemAtIndex:(NSUInteger)index
{
    GOLCell *cell = [self.world cellAtRow:index / self.columns col:index % self.columns];
    if ([cell isAlive]) {
        return CellStateAlive;
    } else {
        return CellStateDead;
    }
}

@end
