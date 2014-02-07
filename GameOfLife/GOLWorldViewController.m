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
#import "UIBarButtonItem+flexibleSpaceItem.h"

typedef enum {
    ToolbarButtonIndexPlay,
    ToolbarButtonIndexPause,
    ToolbarButtonIndexStop,
    ToolbarButtonIndexRandom,
} ToolbarButtonIndex;

@interface GOLWorldViewController ()<GOLWorldViewDataSource>
@property (nonatomic, strong) GOLWorldViewModel *worldViewModel;
@property (nonatomic, weak) IBOutlet GOLWorldView *worldView;
@property (nonatomic, weak) IBOutlet UILabel *generationCountLabel;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *segmentControlWrapper;
@property (nonatomic, weak) IBOutlet UISegmentedControl *speedSegmentedControl;

@property (nonatomic, strong) UIBarButtonItem *playButton;
@property (nonatomic, strong) UIBarButtonItem *pauseButton;
@property (nonatomic, strong) UIBarButtonItem *stopButton;
@property (nonatomic, strong) UIBarButtonItem *randomButton;
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
    
    RACSignal *stopHidden = RACObserve(self.worldViewModel, stopButtonHidden);
    RACSignal *randomHidden = RACObserve(self.worldViewModel, randomizeButtonHidden);
    RACSignal *playHidden = RACObserve(self.worldViewModel, playButtonHidden);
    RACSignal *pauseHidden = RACObserve(self.worldViewModel, pauseButtonHidden);
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil];
    NSArray *basicElements = @[self.segmentControlWrapper, flexibleSpace];
    
    [[[RACSignal combineLatest:@[playHidden, pauseHidden, stopHidden, randomHidden]]
      map:^id(RACTuple *flags) {
          //for each flag, add the UIBarButtonItem corresponding and add it to an array if it is not hidden
          __block NSUInteger i = 0;
          NSMutableArray *initialSequence = [NSMutableArray arrayWithObject:[UIBarButtonItem flexibleSpaceItem]];
          return [flags.allObjects.rac_sequence foldLeftWithStart:initialSequence reduce:^id(NSMutableArray *accumulator, NSNumber *hidden) {
              @strongify(self);
              if (![hidden boolValue]) {
                  [accumulator addObject:[self buttonAtIndex:(ToolbarButtonIndex)i]];
                  [accumulator addObject:[UIBarButtonItem flexibleSpaceItem]];
              }
              i++;
              return accumulator;
          }];
      }]
     // the array of UIBarButton item is set on the toolbar
     subscribeNext:^(NSMutableArray *sequence) {
         self.toolbar.items = [basicElements arrayByAddingObjectsFromArray:sequence];
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

#pragma mark - Buttons

- (UIBarButtonItem *)playButton
{
    if (_playButton == nil) {
        _playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playSimulation:)];
    }
    return _playButton;
}

- (UIBarButtonItem *)pauseButton
{
    if (_pauseButton == nil) {
        _pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseSimulation:)];
    }
    return _pauseButton;
}

- (UIBarButtonItem *)randomButton
{
    if (_randomButton == nil) {
        _randomButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(randomizeWorld:)];
    }
    return _randomButton;
}

- (UIBarButtonItem *)stopButton
{
    if (_stopButton == nil) {
        _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopSimulation:)];
    }
    return _stopButton;
}

- (UIBarButtonItem *)buttonAtIndex:(ToolbarButtonIndex)index
{
    switch (index) {
        case ToolbarButtonIndexPlay:
            return self.playButton;
            
        case ToolbarButtonIndexPause:
            return self.pauseButton;
            
        case ToolbarButtonIndexStop:
            return self.stopButton;
            
        case ToolbarButtonIndexRandom:
            return self.randomButton;
            
        default:
            NSAssert1(NO, @"Unkown Button index", index);
    }
    return nil;
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
- (IBAction)playSimulation:(id)sender
{
    [self.worldViewModel play];
}

- (IBAction)pauseSimulation:(id)sender
{
    [self.worldViewModel pause];
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
