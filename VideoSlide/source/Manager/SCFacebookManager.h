//
//  SCFacebookManager.h
//  SlideshowCreator
//
//  Created 10/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCFacebookShareViewController;

@interface SCFacebookManager : SCBaseManager

@property (nonatomic,strong) SCFacebookShareViewController  *facebookShareDialogView;
@property (nonatomic,strong) NSMutableArray                 *uploadArray; // contains SCUploadObject(s)
@property (nonatomic,strong) NSString                       *loginForString;

- (id)init;

// facebook methods
- (BOOL)isFacebookLoggedIn;
- (void)facebookLogIn;
- (void)facebookLogOut;
- (void)facebookUploadVideo;
- (void)facebookPostStatus;
// facebook share dialog
- (void)facebookOpenShareDialog;
- (void)facebookCloseShareDialog;
@end
