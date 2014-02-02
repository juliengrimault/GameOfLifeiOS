//
//  GOLWolrdView.h
//  GameOfLife
//
//  Created by Julien on 2/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GOLCellState.h"
@class GOLWorldView;


@protocol GOLWorldViewDataSource <NSObject>

- (NSUInteger)numberOfRowsInWorldView:(GOLWorldView *)worldView;
- (NSUInteger)numberOfColumnInWorldView:(GOLWorldView *)worldView;
- (CellState)worldView:(GOLWorldView *)worldView cellStateForRow:(NSUInteger)row column:(NSUInteger)column;

@end


@interface GOLWorldView : UIView

@property (nonatomic, weak) id<GOLWorldViewDataSource> dataSource;

@end
