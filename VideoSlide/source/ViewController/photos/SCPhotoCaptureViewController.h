//
//  SCPhotoCaptureViewController.h
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"

@protocol SCPhotoCaptureViewControllerDelegate <NSObject>
@optional
- (void)photoTakeWithCamera:(SCSlideComposition*)image;
@end

@interface SCPhotoCaptureViewController : SCViewController

@property(nonatomic,weak) id <SCPhotoCaptureViewControllerDelegate> delegate;

@end
