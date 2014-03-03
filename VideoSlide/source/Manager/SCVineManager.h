//
//  SCVineManager.h
//  SlideshowCreator
//
//  Created 12/5/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCVineAuthenticateViewController;

@interface SCVineManager : SCBaseManager


@property (nonatomic,strong) NSString *vineSessionID;

@property (nonatomic,strong) NSString *videoUploadedURL;
@property (nonatomic,strong) NSString *thumbnailUploadedURL;

@property (nonatomic,strong) NSString *_videoUrl;
@property (nonatomic,strong) NSString *_thumbnailUrl;
@property (nonatomic,strong) NSURLConnection *_connection;
@property (nonatomic,strong) NSString *outputURL;
@property (nonatomic,strong) UIImage    *thumbnailImage;

@property (nonatomic,strong) NSString   *loginForString;

@property (nonatomic,strong) NSMutableArray *uploadArray;

- (id)init;


- (void)uploadVideo;
- (void)uploadThumbnail;
- (void)createPost;

- (void)uploadToVine;

- (BOOL)isVineLoggedIn;
- (void)login;
- (void)logout;

- (void)saveAuthenticate;
- (void)loadAuthenticate;
- (void)clearAllAuthenticate;

@end
