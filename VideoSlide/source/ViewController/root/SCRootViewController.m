//
//  SCRootViewController.m
//  SlideshowCreator
//
//  Created 9/5/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCRootViewController.h"

@interface SCRootViewController ()

@end

@implementation SCRootViewController

@synthesize delegate = _delegate;
@synthesize topViewController = _topViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //init file manager
    [SCFileManager getInstance];
    [SCFileManager deleteAllFileFromTemp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - get/set

- (void)setTopViewController:(SCViewController *)topViewController
{
    if(_topViewController.view.superview)
    {
        [_topViewController.view removeFromSuperview];
        _topViewController = nil;
    }
    _topViewController = topViewController;
    _topViewController.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    [self.view addSubview:_topViewController.view];
}


#pragma mark - actions

#pragma mark - class methods


@end

