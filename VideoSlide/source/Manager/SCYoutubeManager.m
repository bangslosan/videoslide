//
//  SCYoutubeManager.m
//  SlideshowCreator
//
//  Created 10/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCYoutubeManager.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLYouTube.h"
#import "GTLUtilities.h"
#import "GTMHTTPUploadFetcher.h"
#import "GTMHTTPFetcherLogging.h"

@implementation SCYoutubeManager

//@synthesize youTubeService;
@synthesize uploadArray;
@synthesize loginForString;

#pragma mark - Youtube SDK
#pragma mark - Youtube Authenticate

- (id)init {
    self = [super init];
    if (self) {
        self.uploadArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isYoutubeLoggedIn {
    
    //[self youtubeRememberLogIn];
    
    GTMOAuth2Authentication *auth = self.youTubeService.authorizer;
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        //return auth.userEmail;
        return YES;
    } else {
        
        GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:SC_YOUTUBE_KEYCHAIN_ITEM_NAME
                                                                                              clientID:SC_YOUTUBE_APP_ID
                                                                                          clientSecret:SC_YOUTUBE_APP_SECRET];
        self.youTubeService.authorizer = auth;
        
        return auth.canAuthorize;
//        return NO;
    }
}

- (void)youtubeLogIn {
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeYouTube
                                                                clientID:SC_YOUTUBE_APP_ID
                                                            clientSecret:SC_YOUTUBE_APP_SECRET
                                                        keychainItemName:SC_YOUTUBE_KEYCHAIN_ITEM_NAME
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[SCScreenManager getInstance].rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    
    self.youTubeService.authorizer = auth;
    
    [[SCScreenManager getInstance].rootViewController dismissViewControllerAnimated:YES completion:^(){
        if (error != nil) {
            // Authentication failed
            NSLog(@"authenticate youtube failed");
        } else {
            // Authentication succeeded
            // Make some API calls
            NSLog(@"authenticate youtube OK OK OK!");
            if ([self.loginForString isEqualToString:SCNotificationYoutubeDidLogIn]) {
                [self sendNotification:SCNotificationYoutubeDidLogIn];
            } else if ([self.loginForString isEqualToString:SCNotificationYoutubeDidLogInForUpload]) {
                [self sendNotification:SCNotificationYoutubeDidLogInForUpload];
            }
            
        }
    }];

}

- (void)youtubeRememberLogIn {
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:SC_YOUTUBE_KEYCHAIN_ITEM_NAME
                                                                                          clientID:SC_YOUTUBE_APP_ID
                                                                                      clientSecret:SC_YOUTUBE_APP_SECRET];
    self.youTubeService.authorizer = auth;
}

- (GTLServiceYouTube *)youTubeService {
    static GTLServiceYouTube *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLServiceYouTube alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    });
    return service;
}

- (void)youtubeLogOut {
    GTLServiceYouTube *service = self.youTubeService;
    
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:SC_YOUTUBE_KEYCHAIN_ITEM_NAME];
    service.authorizer = nil;
    
    [self sendNotification:SCNotificationYoutubeDidLogOut];
}




@end
