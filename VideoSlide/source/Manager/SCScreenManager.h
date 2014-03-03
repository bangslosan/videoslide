//
//  SCScreenManager.h
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"
#import "SCViewController.h"
#import "SCRootViewController.h"
#import "SCNavigationController.h"

@interface SCScreenManager : SCBaseManager

@property (nonatomic, strong) SCViewController       *currentVC;
@property (nonatomic, strong) SCViewController *currentPresentVC;
@property (nonatomic, strong) SCNavigationController *navController;
@property (nonatomic, strong) SCNavigationController *presentNavController;

@property (nonatomic, strong) SCRootViewController   *rootViewController;
@property (nonatomic, strong) NSMutableDictionary *transitData;
@property (nonatomic) SCEnumScreen currentScreen;
@property (nonatomic) SCEnumScreen lastScreen;
@property (nonatomic) SCEnumScreen lastRelatedScreen;


+ (SCScreenManager*)getInstance;
- (void)gotoScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data;
- (void)switchScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data;
- (void)presentScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data;
- (void)presentScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data animated:(BOOL)animated;

- (void)goBack;
- (void)dismissCurrentPresentScreenWithAnimated:(BOOL)animated completion:(void (^)(void))completionBlock;

- (void)playMovieWithUrl:(NSURL*)url;
- (void)clearAllHistory;
- (void)backToHome;
- (void)popToScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data;



@end
