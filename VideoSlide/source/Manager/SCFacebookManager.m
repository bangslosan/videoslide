//
//  SCFacebookManager.m
//  SlideshowCreator
//
//  Created 10/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCFacebookManager.h"
#import "SCFacebookShareViewController.h"


@interface SCFacebookManager ()  <SCFacebookShareViewControllerDelegate>

@end

@implementation SCFacebookManager
@synthesize facebookShareDialogView;
@synthesize uploadArray;
@synthesize loginForString;

#pragma mark - FACEBOOK SDK
#pragma mark - Facebook Authenticate
- (id)init {
    self = [super init];
    if (self) {
        self.uploadArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isFacebookLoggedIn {
    //if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
   /* if (FBSession.activeSession.state == FBSessionStateOpen) {
        return YES;
    } else {
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            [self facebookLogIn];
        } else {
            return NO;
        }
    }*/
    
    return NO;
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            // did login
            if ([self.loginForString isEqualToString:SCNotificationFacebookDidLogInForShareVideo]) {
                [self sendNotification:SCNotificationFacebookDidLogInForShareVideo];
            } else {
                [self sendNotification:SCNotificationFacebookDidLogIn];
            }
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            // not yet login, required login again
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)facebookLogIn {

    NSArray* permissions = [[NSArray alloc] initWithObjects:@"publish_stream", nil];
    
    [FBSession openActiveSessionWithPublishPermissions:permissions
                                       defaultAudience:FBSessionDefaultAudienceEveryone
                                          allowLoginUI:YES
                                     completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                         [self sessionStateChanged:session state:state error:error];
                                     }
    ];
    
}

- (void)facebookLogOut {
    [FBSession.activeSession closeAndClearTokenInformation];
}

/*
- (void)facebookUploadVideo {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Project Title" ofType:@"mov"];
    NSData *videoData = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:videoData forKey:@"Project Title.mov"];
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/videos" parameters:parameters HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"result: %@, error: %@", result, error);
    }];
}
*/

- (void)facebookPostStatus {
    // First request posts a status update
    NSDictionary *params = [[NSDictionary alloc]
                            initWithObjectsAndKeys:
                            @"I am using VideoRize iPhone app. It is so cool.", @"message",
                            nil];
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"facebook post status result: %@, error: %@", result, error);
        [self sendNotification:SCNotificationFacebookShared];
    }];
}

- (void)facebookPostStatusWithText:(NSString*)text {
    // First request posts a status update
    NSDictionary *params = [[NSDictionary alloc]
                            initWithObjectsAndKeys:
                            text, @"message",
                            nil];
    FBRequest *request = [FBRequest requestWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"facebook post status result: %@, error: %@", result, error);
        [SCSocialManager getInstance].numShareFacebook++;
        [[SCSocialManager getInstance] saveNumberOfSharing];
        [self sendNotification:SCNotificationFacebookShared];
    }];
}

#pragma mark - Facebook share dialog
- (void)facebookOpenShareDialog {
    self.facebookShareDialogView = [[SCFacebookShareViewController alloc] initWithNibName:@"SCFacebookShareViewController" bundle:nil];
    self.facebookShareDialogView.delegate = self;
//    [[SCScreenManager getInstance].rootViewController presentViewController:self.facebookShareDialogView animated:YES completion:^{
//        self.facebookShareDialogView.view.backgroundColor = [UIColor clearColor];
//    }];
    
    [[SCScreenManager getInstance].rootViewController.view addSubview:self.facebookShareDialogView.view];
    [self.facebookShareDialogView.statusTextView becomeFirstResponder];
    
    
}

- (void)facebookCloseShareDialog {
    //[[SCScreenManager getInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
    [self.facebookShareDialogView.view removeFromSuperview];
}

- (void)cancelFacebook {
    [self facebookCloseShareDialog];
}

- (void)postToFacebook:(NSString *)text {
    [self facebookPostStatusWithText:text];
    [self facebookCloseShareDialog];
}

@end
