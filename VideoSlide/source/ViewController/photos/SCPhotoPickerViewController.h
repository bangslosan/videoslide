//
//  SCPhotoPickerViewController.h
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCPhotoItemView.h"

@protocol SCPhotoPickerViewControllerDelegate <NSObject>
@optional
- (void)dismissPhotoPickerWithData:(NSArray*)array;
- (void)dismissPhotoPicker;
- (void)dismissPhotoPickerWithSlideComposition:(SCSlideComposition*)slideComposition;
@end

@interface SCPhotoPickerViewController : SCViewController

@property (nonatomic,weak) id <SCPhotoPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) ALAssetsGroup     *assetGroup;
@property (nonatomic, strong) NSMutableArray    *data;

- (void)reloadWithData:(NSMutableArray*)array;

@end
