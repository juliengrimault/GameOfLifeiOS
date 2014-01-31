//
//  GOLGrid.h
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^GridInitBlock)(NSUInteger row, NSUInteger column);
typedef void(^GridEnumerateBlock)(NSUInteger row, NSUInteger column, id object);

@interface GOLGrid : NSObject

@property (nonatomic, readonly) NSUInteger size;

- (id)initWithSize:(NSUInteger)size;
- (id)initWithSize:(NSUInteger)size cellBlock:(GridInitBlock)initBlock;

- (id)cellAtRow:(NSUInteger)row col:(NSUInteger)col;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

- (NSArray *)neighboursAtRow:(NSUInteger)row col:(NSUInteger)col;

- (void)enumerateCells:(GridEnumerateBlock)block;
@end
