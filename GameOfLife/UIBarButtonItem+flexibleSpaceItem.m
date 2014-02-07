//
//  UIBarButtonItem+flexibleSpaceItem.m
//  GameOfLife
//
//  Created by Julien on 7/2/14.
//  Copyright (c) 2014 julien. All rights reserved.
//

#import "UIBarButtonItem+flexibleSpaceItem.h"

@implementation UIBarButtonItem (flexibleSpaceItem)

+ (instancetype) flexibleSpaceItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

@end
