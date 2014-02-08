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

@interface GOLWorldViewController ()<GOLWorldViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) GOLWorldViewModel *worldViewModel;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet GOLWorldView *worldView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *generationCountLabel;
@property (nonatomic, weak) IBOutlet UIToolbar *topToolbar;
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
    
    CGRect worldViewFrame = CGRectMake(0, 0, self.worldViewModel.columns * 8, self.worldViewModel.rows * 8);
    GOLWorldView *worldView = [[GOLWorldView alloc] initWithFrame:worldViewFrame];
    self.worldView = worldView;
    self.worldView.dataSource = self;

    CGFloat xScale = self.scrollView.bounds.size.width / worldViewFrame.size.width;
    CGFloat yScale = self.scrollView.bounds.size.height / worldViewFrame.size.height;

    CGFloat minScale = MIN(xScale, yScale);
    
    [self.scrollView addSubview:self.worldView];
    self.scrollView.contentSize = self.worldView.bounds.size;
    self.scrollView.minimumZoomScale = minScale;
    
    
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
        [self.worldView setNeedsDisplayInRect:[self worldViewDisplayedFrame]];
    }];
    
    [RACObserve(self.worldViewModel, generationCount) subscribeNext:^(NSNumber *count) {
        [self.generationCountLabel setTitle:[count stringValue]];
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
- (void)playSimulation:(id)sender
{
    [self.worldViewModel play];
    [self fadeControls:YES];
}

- (void)pauseSimulation:(id)sender
{
    [self.worldViewModel pause];
}

- (void)stopSimulation:(id)sender
{
    [self.worldViewModel stop];
    [self.worldView setNeedsDisplayInRect:[self worldViewDisplayedFrame]];
}

- (void)randomizeWorld:(id)sender
{
    [self.worldViewModel randomize];
    [self.worldView setNeedsDisplayInRect:[self worldViewDisplayedFrame]];
}

#pragma mark - TapGestureRecognizer
- (IBAction)viewWasTapped:(UITapGestureRecognizer *)recognizer
{
    [self fadeControls:!self.toolbar.hidden];
}

- (void)fadeControls:(BOOL)hide
{
    NSTimeInterval fadeDuration = 0.3;
    if (!hide && self.toolbar.hidden) {
        self.toolbar.hidden = NO;
        self.topToolbar.hidden = NO;
        self.toolbar.alpha = 0;
        self.topToolbar.alpha = 0;
        [UIView animateWithDuration:fadeDuration
                         animations:^{
                             self.toolbar.alpha = 1;
                             self.topToolbar.alpha = 1;
                         }];
    } else if (hide && !self.toolbar.hidden) {
        [UIView animateWithDuration:fadeDuration
                         animations:^{
                             self.toolbar.alpha = 0;
                             self.topToolbar.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             self.toolbar.hidden = YES;
                             self.toolbar.alpha = 1;
                             self.topToolbar.hidden = YES;
                             self.topToolbar.alpha = 1;
                         }];
    }
    
    
}

- (IBAction)viewWasDoubleTapped:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.scrollView.zoomScale < self.scrollView.maximumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    [self.scrollView setNeedsDisplayInRect:[self worldViewDisplayedFrame]];
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.worldView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self.worldView setNeedsDisplayInRect:[self worldViewDisplayedFrame]];
}

- (CGRect)worldViewDisplayedFrame
{
    CGPoint offset = self.scrollView.contentOffset;
    CGRect rect = CGRectMake(offset.x, offset.y,
                             self.scrollView.bounds.size.width,
                             self.scrollView.bounds.size.height);
    return CGRectApplyAffineTransform(rect, CGAffineTransformInvert(self.worldView.transform));
}
@end
