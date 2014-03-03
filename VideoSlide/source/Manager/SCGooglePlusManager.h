//
//  SCGooglePlusManager.h
//  SlideshowCreator
//
//  Created 10/30/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCBaseManager.h"

@class GTLServicePlus;
@class GTLPlusMoment;
@class SCGooglePlusShareViewController;

@interface SCGooglePlusManager : SCBaseManager

@property (nonatomic,readonly) GTLServicePlus                  *googlePlusService;
@property (nonatomic,strong)   SCGooglePlusShareViewController *googlePlusShareDialogView;

- (id)init;

// google plus
- (BOOL)isGooglePlusLoggedIn;
- (void)googlePlusLogIn;
- (void)googlePlusLogOut;
- (void)googlePlusRememberLogIn;
//- (void)googlePlusPost;
- (void)share;
@end
