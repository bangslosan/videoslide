//
//  SCViewController.h
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"


@interface SCViewController : UIViewController  {
    Reachability* internetReach;
}

@property (nonatomic)         SCEnumScreen   lastScreen;
@property (nonatomic)         SCEnumScreen   lastRelatedScreen;
@property (nonatomic)         SCEnumScreen   screenNameType;
@property (nonatomic, assign) BOOL            isActive;

- (void)clearAll;
- (void)gotoScreen:(SCEnumScreen)screenName data:(NSMutableDictionary *)data;
- (void)presentScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data;
- (void)presentScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data animated:(BOOL)animated;
- (void)goBack;
- (void)dismissPresentScreen;
- (void)dismissPresentScreenWithAnimated:(BOOL)animated completion:(void (^)(void))completionBlock;

- (void)showLoading;
- (void)showLoadingWithFrame:(CGRect)frame;
- (void)hideLoading;

- (SCEnumScreen)getCurrentPageType;
- (SCViewController*)currentPresentVC;
- (NSMutableDictionary*)lastData;

- (void)showInternetSignalAlert;
- (void)hideInternetSignalAlert;

- (void)sendNotification:(NSString *)notificationName;;
- (void)sendNotification:(NSString *)notificationName body:(id)body type:(id)type;
- (NSArray *)listNotificationInterests;
- (void)handleNotification:(NSNotification *)notification;

- (void)viewActionAfterTurningBack;

- (void)fadeInWithCompletion:(void (^)(void))completionBlock;
- (void)fadeOutWithCompletion:(void (^)(void))completionBlock;

- (void)zoomInWithCompletion:(void (^)(void))completionBlock;
- (void)zoomOutWithCompletion:(void (^)(void))completionBlock;

- (void)moveUpWithCompletion:(void (^)(void))completionBlock;
- (void)moveDownWithCompletion:(void (^)(void))completionBlock;

@end
