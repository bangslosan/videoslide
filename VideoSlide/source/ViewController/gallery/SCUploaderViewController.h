//
//  SCUploaderViewController.h
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"

@interface SCUploaderViewController : SCViewController

@property (nonatomic,strong) IBOutlet UITableView       *uploadTableView;
@property (nonatomic,strong) IBOutlet SCUploadItemCell  *uploadItemCell;

@end
