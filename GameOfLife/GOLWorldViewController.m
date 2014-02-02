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
#import "GOLWorldView.h"

@interface GOLWorldViewController ()<GOLWorldViewDataSource>
@property (nonatomic, strong) GOLWorldViewModel *worldViewModel;
@property (nonatomic, weak) IBOutlet GOLWorldView *worldView;
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
    
    self.worldView.dataSource = self;
    
    RAC(self.generationCountLabel, text) = [RACObserve(self.worldViewModel, generationCount) map:^id(NSNumber *count) {
        return [count stringValue];
    }];
    
    RAC(self.stopButton, hidden) = RACObserve(self.worldViewModel, stopButtonHidden);
    RAC(self.randomButton, hidden) = RACObserve(self.worldViewModel, randomizeButtonHidden);
    
    // setup 2 ways binding between the segmented control and the tickInterval in the ViewModel.
    // we need to do a transformation of the data between a NSTimeInterval and an index in the segmented control.
    RACChannelTerminal *vmTickIntervalTerminal = RACChannelTo(self.worldViewModel, tickInterval);
    RACChannelTerminal *segmentedControlTerminal = [self.speedSegmentedControl rac_newSelectedSegmentIndexChannelWithNilValue:@1];
    [[vmTickIntervalTerminal map:^id(NSNumber *tick) {
        return @([UISegmentedControl indexForTickInterval:[tick doubleValue]]);
    }] subscribe:segmentedControlTerminal];
    
    [[segmentedControlTerminal map:^id(NSNumber *selectedIndex) {
        return @([UISegmentedControl tickIntervalForIndex:[selectedIndex integerValue]]);
    }] subscribe:vmTickIntervalTerminal];
    
    
    @weakify(self);
    // reload the collecitonview whenever we send a new tick
    [self.worldViewModel.clock subscribeNext:^(id x) {
        @strongify(self);
        [self.worldView setNeedsDisplay];
    }];
    
    // update the play_pause button title when needed
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



#pragma mark - GOLWorldViewDataSource
- (NSUInteger)numberOfRowsInWorldView:(GOLWorldView *)worldView
{
    return self.worldViewModel.rows;
}

- (NSUInteger)numberOfColumnInWorldView:(GOLWorldView *)worldView
{
    return self.worldViewModel.columns;
}

- (CellState)worldView:(GOLWorldView *)worldView cellStateForRow:(NSUInteger)row column:(NSUInteger)column
{
    return [self.worldViewModel cellStateForRow:row column:column];
}

#pragma mark - UIButton
- (IBAction)playOrPauseSimulation:(id)sender
{
    if (self.worldViewModel.running)
        [self.worldViewModel pause];
    else
        [self.worldViewModel play];
}

- (IBAction)stopSimulation:(id)sender
{
    [self.worldViewModel stop];
    [self.worldView setNeedsDisplay];
}

- (IBAction)randomizeWorld:(id)sender
{
    [self.worldViewModel randomize];
    [self.worldView setNeedsDisplay];
}

@end
