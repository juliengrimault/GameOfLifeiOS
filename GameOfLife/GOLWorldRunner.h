//
//  GOLWorldRunner.h
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GOLWorld;
@class RACSignal;

@interface GOLWorldRunner : NSObject

@property (nonatomic, readonly) RACSignal *clock;
@property (nonatomic) NSTimeInterval tickInterval;

@property (nonatomic, readonly, getter = isRunning) BOOL running;
- (void)play;
- (void)pause;
- (void)stop;

- (id)initWithWorld:(GOLWorld *)world;



@end
