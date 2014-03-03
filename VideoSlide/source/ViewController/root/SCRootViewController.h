//
//  SCRootViewController.h
//  SlideshowCreator
//
//  Created 9/5/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"
#import "MBProgressHUD.h"

@protocol SCRootViewControllerProtocol


@end

@interface SCRootViewController : SCViewController

@property (nonatomic, strong) SCViewController                 *topViewController;
@property (nonatomic, weak) id<SCRootViewControllerProtocol>   delegate;
@property (nonatomic, strong) MBProgressHUD                    *HUD;


@end