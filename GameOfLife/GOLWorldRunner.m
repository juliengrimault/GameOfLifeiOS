//
//  GOLWorldRunner.m
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "GOLWorldRunner.h"
#import "GOLWorld.h"

@interface GOLWorldRunner()
@property (nonatomic, strong) GOLWorld *world;
@property (nonatomic, strong) RACSignal *clock;
@end

@implementation GOLWorldRunner

- (id)initWithWorld:(GOLWorld *)world
{
    self = [super init];
    if (!self) return nil;
    
    _world = world;
    _tickInterval = 0.5;
    
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
@end
