//
//  GOLWorldViewController.m
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GOLWorldViewController.h"
#import "GOLWorldViewModel.h"
#import "UISegmentedControl+GOLWorld.h"

@interface GOLWorldViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) GOLWorldViewModel *worldViewModel;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *generationCountLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *speedSegmentedControl;
@property (nonatomic, weak) IBOutlet UIButton *playPauseButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *randomButton;
@end

@implementation GOLWorldViewController

- (id)initWithWorldViewModel:(GOLWorldViewModel *)worldViewModel
{
    self = [super init];
    if (!self) return nil;
    
    _worldViewModel = worldViewModel;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    RAC(self.generationCountLabel, text) = [RACObserve(self.worldViewModel, generationCount) map:^id(NSNumber *count) {
        return [count stringValue];
    }];
    
    RAC(self.stopButton, hidden) = RACObserve(self.worldViewModel, stopButtonHidden);
    RAC(self.randomButton, hidden) = RACObserve(self.worldViewModel, randomizeButtonHidden);
    
    RACChannelTerminal *vmTickIntervalTerminal = RACChannelTo(self.worldViewModel, tickInterval);
    RACChannelTerminal *segmentedControlTerminal = [self.speedSegmentedControl rac_newSelectedSegmentIndexChannelWithNilValue:@1];
    [[vmTickIntervalTerminal map:^id(NSNumber *tick) {
        return @([UISegmentedControl indexForTickInterval:[tick doubleValue]]);
    }] subscribe:segmentedControlTerminal];
    
    [[segmentedControlTerminal map:^id(NSNumber *selectedIndex) {
        return @([UISegmentedControl tickIntervalForIndex:[selectedIndex integerValue]]);
    }] subscribe:vmTickIntervalTerminal];
    
    
    @weakify(self);
    [self.worldViewModel.clock subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView reloadData];
    }];
    
    [RACObserve(self.worldViewModel, playPauseButtonTitle) subscribeNext:^(id x) {
        @strongify(self);
        [self.playPauseButton setTitle:x forState:UIControlStateNormal];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.worldViewModel.active = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.worldViewModel.active = NO;
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.worldViewModel.numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CellState state = [self.worldViewModel cellStateForItemAtIndex:indexPath.item];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    UIColor *color = state == CellStateAlive ? [UIColor blackColor] : [UIColor whiteColor];
    cell.contentView.backgroundColor = color;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UIButton
- (IBAction)startOrStopSimulation:(id)sender
{
    self.worldViewModel.running = !self.worldViewModel.running;
}

@end
