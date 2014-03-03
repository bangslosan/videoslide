//
//  SCInstagramManager.h
//  SlideshowCreator
//
//  Created 11/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"
#import "SCInstagramAuthenticateViewController.h"

@class SCInstagramUserModel;

@interface SCInstagramManager : SCBaseManager <SCInstagramAuthenticateViewControllerDelegate>

@property (nonatomic,strong) NSMutableArray                         *instagramPhotoArray;
@property (nonatomic,strong) NSMutableArray                         *selectedInstagramPhotoArray;
@property (nonatomic,strong) SCInstagramAuthenticateViewController  *instagramAuthenticateViewController;
@property (nonatomic,strong) NSString                               *nextMaxIDPaging;
@property (nonatomic,strong) SCInstagramUserModel                   *instagramUserModel;
@property (nonatomic,strong) NSString                               *currentRequest;
@property (nonatomic,strong) NSString                               *loginFor;

- (id)init;

- (void)instagramLogIn;
- (void)instagramLogOut;
- (BOOL)isInstagramLoggedIn;

- (NSString*)instagramUsername;
- (NSString*)instagramMediaCount;
- (NSString*)instagramAvatar;

- (void)populateSelectedArray;
- (void)resetSelectedArray;

- (void)requestInstagramPhotoInBackground;
- (void)requestMoreInstagramPhoto;

@end
