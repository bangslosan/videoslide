//
//  SCHomeViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCHomeViewController.h"
#import "AppDelegate.h"

@interface SCHomeViewController ()

@property (nonatomic,strong) IBOutlet UIButton      *signInInstagramBtn;
@property (nonatomic,strong) IBOutlet UIView        *loggedInInfoView;
@property (nonatomic,strong) IBOutlet UILabel       *instagramUsernameLb;
@property (nonatomic,strong) IBOutlet UILabel       *instagramNumOfPhotosLb;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView   *loadingIndicatorView;

- (IBAction)onSettingBtn:(id)sender;
- (IBAction)onCreateBtn:(id)sender;
- (IBAction)onLibraryBtn:(id)sender;
- (IBAction)onSignInInstagramBtn:(id)sender;
- (IBAction)onLogOutInstagramBtn:(id)sender;

@end

@implementation SCHomeViewController
@synthesize signInInstagramBtn = _signInInstagramBtn;
@synthesize loggedInInfoView = _loggedInInfoView;
@synthesize instagramNumOfPhotosLb = _instagramNumOfPhotosLb;
@synthesize instagramUsernameLb = _instagramUsernameLb;
@synthesize loadingIndicatorView = _loadingIndicatorView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadInstagramAuthenticateStatus];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fillInstagramUserData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)onSettingBtn:(id)sender {
    [self gotoScreen:SCEnumSettingScreen data:nil];
}

- (IBAction)onCreateBtn:(id)sender {
    [self gotoScreen:SCEnumPhotosScreen data:nil];
}

- (IBAction)onLibraryBtn:(id)sender
{
    [self gotoScreen:SCEnumGalleryScreen data:nil];
}

- (IBAction)onSignInInstagramBtn:(id)sender {
    [self doInstagramLogIn];
}

- (IBAction)onLogOutInstagramBtn:(id)sender {
    [self doInstagramLogOut];
}

#pragma mark - Instagram Authenticate
- (void)loadInstagramAuthenticateStatus {
   /* if ([[SCSocialManager getInstance].instagramManager isInstagramLoggedIn]) {
        [self loadInstagramSessionValidState];
        [[SCSocialManager getInstance].instagramManager requestInstagramPhotoInBackground];
    } else {
        [self loadInstagramSessionInvalidState];
    }*/
}

- (void)loadInstagramSessionValidState {
    self.signInInstagramBtn.hidden = YES;
    self.loggedInInfoView.hidden = NO;
    [self fillInstagramUserData];
}

- (void)loadInstagramSessionInvalidState {
    self.signInInstagramBtn.hidden = NO;
    self.loggedInInfoView.hidden = YES;
}

#pragma mark - local Instagram methods
- (void)doInstagramLogIn {
  //  [[SCSocialManager getInstance].instagramManager instagramLogIn];
}

- (void)doInstagramLogOut {
   // [[SCSocialManager getInstance].instagramManager instagramLogOut];
}

- (void)instagramDidLogIn {
    self.signInInstagramBtn.hidden = YES;
    self.loggedInInfoView.hidden = NO;
}

- (void)instagramDidLogout {
    [self loadInstagramSessionInvalidState];
}

- (void)fillInstagramUserData {
    
   /* if ([[SCSocialManager getInstance].instagramManager isInstagramLoggedIn]) {
        self.signInInstagramBtn.hidden = YES;
        self.loggedInInfoView.hidden = NO;
    } else {
        self.signInInstagramBtn.hidden = NO;
        self.loggedInInfoView.hidden = YES;
    }
    
    self.instagramUsernameLb.text = [[SCSocialManager getInstance].instagramManager instagramUsername];
    self.instagramNumOfPhotosLb.text = [NSString stringWithFormat:@"%@ photos", [[SCSocialManager getInstance].instagramManager instagramMediaCount]];*/
}

#pragma mark - notification section
- (NSArray *)listNotificationInterests {
    return [NSArray arrayWithObjects:
            SCNotificationInstagramDidLogIn,
            SCNotificationInstagramDidLogOut,
            nil];
}

- (void)handleNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:SCNotificationInstagramDidLogIn]) {
        [self instagramDidLogIn];
    }
    else if ([notification.name isEqualToString:SCNotificationInstagramDidLogOut]) {
        [self instagramDidLogout];
    }
}

#pragma mark - Indicator view
- (void)startLoading {
    
    self.instagramUsernameLb.hidden = YES;
    self.instagramNumOfPhotosLb.hidden = YES;
    
    self.loadingIndicatorView.hidden = NO;
    [self.loadingIndicatorView startAnimating];
}

- (void)stopLoading {
    
    self.instagramUsernameLb.hidden = NO;
    self.instagramNumOfPhotosLb.hidden = NO;
    
    [self.loadingIndicatorView stopAnimating];
    self.loadingIndicatorView.hidden = YES;
}

- (IBAction)vineTesting:(id)sender {
    [[SCSocialManager getInstance].vineManager login];
}

- (IBAction)vineUploadVideoTesting:(id)sender {
    [[SCSocialManager getInstance].vineManager uploadVideo];
}

- (IBAction)vineUploadThumbTesting:(id)sender {
    [[SCSocialManager getInstance].vineManager uploadThumbnail];
}

- (IBAction)vineCreatePostTesting:(id)sender {
    [[SCSocialManager getInstance].vineManager createPost];
}

@end
