//
//  SCSocialManager.h
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"

@class SCVineManager;

@interface SCSocialManager : SCBaseManager

@property (nonatomic,strong) SCVineManager              *vineManager;

// upload
@property (nonatomic,strong) NSMutableArray             *allUploadItems;

+ (SCSocialManager*)getInstance;


// save to file
- (void)saveAllUploadItems;
- (void)loadAllUploadItems;

// manage number of sharing
- (void)loadNumberOfSharing;
- (void)saveNumberOfSharing;

@end
