//
//  GOLWorldSeeder.h
//  GameOfLife
//
//  Created by Julien on 1/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOLWorldSeeder : NSObject

@property (nonatomic) CGFloat lifeProbability;
- (id)initWithSize:(NSUInteger)size;

- (NSString *)generatePattern;
@end
