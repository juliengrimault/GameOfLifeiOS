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

// The clock sends `next` at every `tickInterval` seconds when the simulation is running.
// each tick correspond to a new generation in the world.
@property (nonatomic, readonly) RACSignal *clock;
@property (nonatomic) NSTimeInterval tickInterval;

// What generatino are we at
@property (nonatomic, readonly) NSUInteger generationCount;

// Indicates if the simulation is currently running
@property (nonatomic, readonly, getter = isRunning) BOOL running;

// control the simulation
- (void)play;
- (void)pause;
//stop will bring back the simulation to its original state. `generationCount` will be 0 again.
- (void)stop;

- (void)randomize;


// UI related
@property (nonatomic, readonly) NSString *playPauseButtonTitle;
@property (nonatomic, readonly, getter = isStopButtonHidden) BOOL stopButtonHidden;
@property (nonatomic, readonly, getter = isRandomizeButtonHidden) BOOL randomizeButtonHidden;

// Info to render the World
@property (nonatomic, readonly) NSUInteger rows;
@property (nonatomic, readonly) NSUInteger columns;
// This is to make it handy to display the world in a CollectionView
@property (nonatomic, readonly) NSUInteger numberOfItems;
- (CellState)cellStateForItemAtIndex:(NSUInteger)index;


- (id)initWithWorld:(GOLWorld *)world;



@end
