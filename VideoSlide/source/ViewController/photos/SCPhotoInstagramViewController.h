//
//  SCPhotoInstagramViewController.h
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"

@protocol SCPhotoInstagramViewControllerDelegate <NSObject>
@optional
- (void)dismissInstagramPhotoViewWithData:(NSArray*)array;
- (void)dismissPhotoPickerWithSlideComposition:(SCSlideComposition*)slideComposition;
@end

@interface SCPhotoInstagramViewController : SCViewController
@property(nonatomic,weak) id <SCPhotoInstagramViewControllerDelegate> delegate;
@end
