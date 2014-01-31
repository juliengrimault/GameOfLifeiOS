//
//  GOLWorldViewController.h
//  GameOfLife
//
//  Created by Julien on 31/1/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GOLWorldViewModel;

@interface GOLWorldViewController : UIViewController

- (id)initWithWorldViewModel:(GOLWorldViewModel *)worldViewModel;

@end
