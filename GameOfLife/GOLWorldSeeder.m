//
//  GOLWorldSeeder.m
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "GOLWorldSeeder.h"

@interface GOLWorldSeeder()
@property (nonatomic) NSUInteger size;
@end

@implementation GOLWorldSeeder

- (id)initWithSize:(NSUInteger)size
{
    self = [super init];
    if (!self) return nil;
    
    _size = size;
    _lifeProbability = 0.2;
   
    [self initializePRNG];
    
    return self;
}

- (void)initializePRNG
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        srand48(time(0));
    });
}

- (NSString *)generatePattern
{
    NSMutableString *pattern = [NSMutableString new];
    for (NSUInteger i = 0; i < self.size; i++) {
        for (NSUInteger j = 0; j < self.size; j++) {
            if (drand48() <= self.lifeProbability) {
                [pattern appendString:@"*"];
            } else {
                [pattern appendString:@"."];
            }
        }
        
        if (i < self.size - 1) {
            [pattern appendString:@"\n"];
        }
    }
    return pattern;
}


@end
