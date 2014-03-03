//
//  SCSettingCell.h
//  SlideshowCreator
//
//  Created 10/5/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCSettingCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView    *socialIconImageView;
@property (nonatomic,strong) IBOutlet UIImageView    *statusImageView;
@property (nonatomic,strong) IBOutlet UIImageView    *cellBackgroundImage;
@property (nonatomic,strong) IBOutlet UILabel        *socialNameLb;

@end
