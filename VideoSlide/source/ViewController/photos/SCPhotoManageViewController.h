//
//  SCPhotoManageViewController.h
//  SlideshowCreator
//
//  Created 11/19/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCPhotoManageViewControllerDelegate <NSObject>
@optional
- (void)dismissPhotoManageWithData:(NSArray *)array;
- (void)dismissPhotoPickerWithSlideComposition:(SCSlideComposition *)slideComposition;
- (void)dismissWithNoPhoto;
@end

@interface SCPhotoManageViewController : SCViewController

@property (nonatomic,weak) id <SCPhotoManageViewControllerDelegate> delegate;
@property (nonatomic,strong) IBOutlet UINavigationController *navigationController;

@end
