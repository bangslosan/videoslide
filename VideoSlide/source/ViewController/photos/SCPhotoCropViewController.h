//
//  SCPhotoCropViewController.h
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"

@protocol SCPhotoCropViewControllerDeletate <NSObject>
@optional
- (void)closeCropViewWithData:(NSMutableArray*)data;
- (void)closeCropViewWithOnePhoto:(SCSlideComposition*)slideComposition;
@end

@interface SCPhotoCropViewController : SCViewController

@property (nonatomic,weak) id <SCPhotoCropViewControllerDeletate> delegate;

@property (nonatomic,strong)    UIImage             *currentOriginalImage;
@property (nonatomic,strong)    NSMutableArray      *data;
@property (nonatomic,assign)    int                 currentPhotoIndex;

@property (nonatomic,assign)    CGRect              instantRectCropped;

@end
