//
//  SCSinglePhotoPickerViewController.h
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCPhotoItemView.h"

@protocol SCSinglePhotoPickerViewControllerDelegate <NSObject>
@optional
- (void)dismissPhotoPickerWithSlideComposition:(SCSlideComposition*)slideComposition;
@end

@interface SCSinglePhotoPickerViewController : SCViewController

@property(nonatomic,weak) id <SCSinglePhotoPickerViewControllerDelegate> delegate;

@end
