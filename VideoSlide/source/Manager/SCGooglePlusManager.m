//
//  SCGooglePlusManager.m
//  SlideshowCreator
//
//  Created 10/30/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCGooglePlusManager.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLPlus.h"
#import "GTLUtilities.h"
#import "GTMHTTPUploadFetcher.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLPlusComment.h"

@interface SCGooglePlusManager ()  <SCGooglePlusShareViewControllerDelegate>

@end

@implementation SCGooglePlusManager
@synthesize googlePlusShareDialogView;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (BOOL)isGooglePlusLoggedIn {
    
    [self googlePlusRememberLogIn];
    
    GTMOAuth2Authentication *auth = self.googlePlusService.authorizer;
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        //return auth.userEmail;
        return YES;
    } else {
        return NO;
    }
}

- (void)googlePlusLogIn {
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScopePlus:kGTLAuthScopePlusLogin
                                                                    clientID:SC_YOUTUBE_APP_ID
                                                                clientSecret:SC_YOUTUBE_APP_SECRET
                                                            keychainItemName:SC_GOOGLE_PLUS_KEYCHAIN_ITEM_NAME
                                                                    delegate:self
                                                            finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[SCScreenManager getInstance].rootViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    
    self.googlePlusService.authorizer = auth;
    
    [[SCScreenManager getInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    
    if (error != nil) {
        // Authentication failed
        NSLog(@"authenticate google plus failed");
    } else {
        // Authentication succeeded
        // Make some API calls
        NSLog(@"authenticate google plus OK OK OK!");
        [self sendNotification:SCNotificationGooglePlusDidLogIn];
        [self showDialog];
    }
}

- (void)googlePlusRememberLogIn {
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:SC_YOUTUBE_KEYCHAIN_ITEM_NAME
                                                                                          clientID:SC_YOUTUBE_APP_ID
                                                                                      clientSecret:SC_GOOGLE_PLUS_KEYCHAIN_ITEM_NAME];
    self.googlePlusService.authorizer = auth;
}

- (GTLServicePlus *)googlePlusService {
    static GTLServicePlus *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLServicePlus alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    });
    return service;
}

- (void)googlePlusLogOut {
    GTLServicePlus *service = self.googlePlusService;
    
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:SC_GOOGLE_PLUS_KEYCHAIN_ITEM_NAME];
    service.authorizer = nil;
    
    [self sendNotification:SCNotificationGooglePlusDidLogOut];
}

- (void)googlePlusPost:(NSString*)text {
    
    /*
    //  Create a new moment
    GTLPlusMoment *moment = [[GTLPlusMoment alloc] init];
    moment.type = @"http://schemas.google.com/AddActivity";
    
    GTLPlusItemScope * target = [[GTLPlusItemScope alloc] init];
    target.url = @"http://example.com/";
//    target.type = @"http://schemas.google.com/AddActivity";
    
    moment.target = target;
    
    GTLQueryPlus *query = [GTLQueryPlus queryForMomentsInsertWithObject:moment userId:@"me" collection:kGTLPlusCollectionVault];
    
    GTLServicePlus *service = self.googlePlusService;
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket * ticket, id object, NSError * error) {

        if (error) {
//            NSLog (@ "% @", error);
//            Else {}
//            NSLog (@ "ticket:% @", ticket);
//            NSLog (@ "object:% @", object);
        }
        NSLog(@"GOOGLEPLUS: %@",[error description]);
    }];
     */
    
    GTMOAuth2Authentication *auth = self.googlePlusService.authorizer;
    
    NSString *postString = [NSString stringWithFormat:@"{\"type\":\"http:\\/\\/schemas.google.com\\/AddActivity\",\"target\":{\"id\":\"vrz\",\"type\":\"http:\\/\\/schemas.google.com\\/AddActivity\",\"description\":\"%@\",\"name\":\"%@\"}}", text, text];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/plus/v1/people/me/moments/vault?access_token=%@&key=%@",  auth.refreshToken, SC_YOUTUBE_APP_ID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    GTMHTTPFetcher *myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    
    [myFetcher setAuthorizer:auth];
    [myFetcher setPostData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
        if (error == nil) {
            NSLog(@"OK %@", [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding]);
            [SCSocialManager getInstance].numShareGooglePlus++;
            [[SCSocialManager getInstance] saveNumberOfSharing];
            [self sendNotification:SCNotificationGooglePlusShared];
        } else {
            NSLog(@"%@", error.localizedDescription);
            [self sendNotification:SCNotificationGooglePlusShareFailed];
        }
        
        [self hideDialog];
    }];
}

- (void)share {
    if ([self isGooglePlusLoggedIn]) {
        // show dialog
//        [self showDialog];
        [self googlePlusLogIn];
    } else {
        // login and then show dialog
        [self googlePlusLogIn];
    }
}

- (void)showDialog {
    self.googlePlusShareDialogView = [[SCGooglePlusShareViewController alloc] initWithNibName:@"SCGooglePlusShareViewController" bundle:nil];
    self.googlePlusShareDialogView.delegate = self;
    [[SCScreenManager getInstance].rootViewController.view addSubview:self.googlePlusShareDialogView.view];
    [self.googlePlusShareDialogView.statusTextView becomeFirstResponder];
}

- (void)hideDialog {
    [self.googlePlusShareDialogView.view removeFromSuperview];
}

- (void)cancelGooglePlus {
    [self hideDialog];
}

- (void)postToGooglePlus:(NSString *)text {
    [self googlePlusPost:text];
}

@end
    