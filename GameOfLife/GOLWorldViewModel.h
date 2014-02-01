//
//  GOLWorldViewModel.h
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveViewModel/ReactiveViewModel.h>
@class GOLWorld;
@class RACCommand;

typedef enum CellState {
    CellStateDead,
    CellStateAlive
} CellState;

@interface GOLWorldViewModel : RVMViewModel

@property (nonatomic, readonly) RACSignal *clock;
@property (nonatomic) NSTimeInterval tickInterval;
@property (nonatomic, readonly) NSUInteger generationCount;

@property (nonatomic, readonly) NSString *playPauseButtonTitle;
@property (nonatomic, readonly, getter = isStopButtonHidden) BOOL stopButtonHidden;
@property (nonatomic, readonly, getter = isRandomizeButtonHidden) BOOL randomizeButtonHidden;

@property (nonatomic, readonly, getter = isRunning) BOOL running;
- (void)play;
- (void)pause;
- (void)stop;

@property (nonatomic, readonly) NSUInteger rows;
@property (nonatomic, readonly) NSUInteger columns;

@property (nonatomic, readonly) NSUInteger numberOfItems;
- (CellState)cellStateForItemAtIndex:(NSUInteger)index;


- (id)initWithWorld:(GOLWorld *)world;



@end
