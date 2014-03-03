//
//  SCSocialManager.h
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"

@class SCInstagramUserModel;
@class SCYoutubeManager;
@class SCEmailManager;
@class SCMessageManager;
@class SCTwitterManager;
@class SCFacebookManager;
@class SCGooglePlusManager;
@class SCInstagramManager;
@class SCVineManager;

@interface SCSocialManager : SCBaseManager

@property (nonatomic,strong) SCYoutubeManager           *youtubeManager;
@property (nonatomic,strong) SCEmailManager             *emailManager;
@property (nonatomic,strong) SCMessageManager           *messageManager;
@property (nonatomic,strong) SCTwitterManager           *twitterManager;
@property (nonatomic,strong) SCFacebookManager          *facebookManager;
@property (nonatomic,strong) SCGooglePlusManager        *googlePlusManager;
@property (nonatomic,strong) SCInstagramManager         *instagramManager;
@property (nonatomic,strong) SCVineManager              *vineManager;

// upload
@property (nonatomic,strong) NSMutableArray             *allUploadItems;

// manage number of share
@property (nonatomic,assign) int                        numShareEmail;
@property (nonatomic,assign) int                        numShareMessage;
@property (nonatomic,assign) int                        numShareFacebook;
@property (nonatomic,assign) int                        numShareTwitter;
@property (nonatomic,assign) int                        numShareGooglePlus;

+ (SCSocialManager*)getInstance;

// google plus
- (BOOL)isGooglePlusLoggedIn;
- (void)googlePlusLogIn;
- (void)googlePlusLogOut;
- (void)googlePlustOpenShareDialog;

// save to file
- (void)saveAllUploadItems;
- (void)loadAllUploadItems;

// manage number of sharing
- (void)loadNumberOfSharing;
- (void)saveNumberOfSharing;

@end
