//
//  SCUploadItemCell.h
//  SlideshowCreator
//
//  Created 10/28/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCUploadObject;

@protocol SCUploadItemCellDelegate <NSObject>
@optional
@end

@interface SCUploadItemCell : UITableViewCell <SCUploadObjectDelegate>

@property (nonatomic,weak) id <SCUploadItemCellDelegate> delegate;

@property (nonatomic,strong) SCUploadObject         *uploadObject;
@property (nonatomic,strong) IBOutlet UILabel       *uploadItemNameLb;
@property (nonatomic,strong) IBOutlet UILabel       *uploadStatusLb;
@property (nonatomic,strong) IBOutlet UIView        *uploadProgressView;
@property (nonatomic,strong) IBOutlet UIImageView   *uploadTypeImgView;
@property (nonatomic,strong) IBOutlet UIButton      *uploadStatusBtn;

@property (nonatomic,strong) IBOutlet UILabel       *testLabel;

- (IBAction)onUploadStatusBtn;
- (void)uploadProgressViewWithValue:(float)progress;

@end
