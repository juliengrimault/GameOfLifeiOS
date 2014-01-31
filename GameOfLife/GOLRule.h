//
//  GOLRule.h
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOLRule : NSObject

- (BOOL)shouldToggle:(BOOL)isAlive liveNeigboursCount:(NSUInteger)count;
@end
