//
//  GOLWorldViewModel.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "GOLWorldViewModel.h"
#import "GOLWorld.h"
#import "GOLCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface GOLWorldViewModel ()
@property (nonatomic, strong) GOLWorld *world;
@property (nonatomic, strong) RACSignal *clock;
@property (nonatomic, strong) RACCommand *start;
@property (nonatomic, strong) RACCommand *stop;
@end

@implementation GOLWorldViewModel

- (id)initWithWorld:(GOLWorld *)world
{
    self = [super init];
    if (!self) return nil;
    
    _world = world;
    _tickInterval = 1.0;
    RAC(self, generationCount) = RACObserve(self.world, generationCount);
    RAC(self, rows) = RACObserve(self.world, size);
    RAC(self, columns) = RACObserve(self.world, size);
    
    
    RAC(self, startStopButtonTitle) = [RACObserve(self, running) map:^id(NSNumber *x) {
        if ([x boolValue]) {
            return NSLocalizedString(@"Stop", nil);
        } else {
            return NSLocalizedString(@"Start", nil);
        }
    }];
    
    @weakify(self);
    self.clock = [[[RACSignal combineLatest:@[self.didBecomeActiveSignal, RACObserve(self, tickInterval) ]
                                     reduce:^id(id x, NSNumber *interval) { return interval; }]
                   map:^RACStream *(NSNumber *interval) {
                       @strongify(self);

                       return [[[RACSignal interval:[interval doubleValue] onScheduler:[RACScheduler mainThreadScheduler]]
                                takeUntil:self.didBecomeInactiveSignal]
                               doNext:^(id x) {
                                   [self.world tick];
                               }];
                   }] switchToLatest];
    
    return self;
}

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
