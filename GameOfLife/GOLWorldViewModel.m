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
    
    RACSignal *runningSignal = RACObserve(self, running);
    
    
    RACSignal *startSignal = [[[[[RACSignal combineLatest:@[runningSignal, RACObserve(self, tickInterval)]]
                               filter:^BOOL(RACTuple *t) {
                                   return [t.first boolValue];
                               }]
                                map:^id(RACTuple *t) {
                                  return t.second;
                              }]
                              setNameWithFormat:@"startClockSignal"] logAll];
    
    RACSignal *stopSignal = [[[runningSignal filter:^BOOL(id value) { return ![value boolValue]; }] setNameWithFormat:@"stopClockSignal"] logAll];
    
    @weakify(self);
    self.clock = [[[[[startSignal map:^RACStream *(NSNumber *interval) {
                       return [[RACSignal interval:[interval doubleValue]
                                          onScheduler:[RACScheduler mainThreadScheduler]]
                               takeUntil:stopSignal];
                    }] switchToLatest]
                    
                   doNext:^(id x) {
                       @strongify(self);
                       [self.world tick];
                   }]
                   
                   setNameWithFormat:@"clockSignal"] logAll];
    
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
