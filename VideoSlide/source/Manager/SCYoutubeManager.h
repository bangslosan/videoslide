//
//  SCYoutubeManager.h
//  SlideshowCreator
//
//  Created 10/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTLServiceYouTube;


@interface SCYoutubeManager : SCBaseManager

@property (nonatomic,readonly) GTLServiceYouTube            *youTubeService;
@property (nonatomic,strong)   NSMutableArray               *uploadArray; // contains SCUploadObject(s)
@property (nonatomic,strong)   NSString                     *loginForString;


- (id)init;

// youtube
- (BOOL)isYoutubeLoggedIn;
- (void)youtubeLogIn;
- (void)youtubeLogOut;
- (void)youtubeUploadVideo;
- (void)youtubeRememberLogIn;


@end
