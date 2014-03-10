//
//  SCViewController.m
//  SlideshowCreator
//
//  Created 8/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCViewController.h"

@interface SCViewController () <MBProgressHUDDelegate>

@property (nonatomic, strong) SCLoadingView      *loadingView;

@end

@implementation SCViewController

@synthesize lastScreen  = _lastScreen;
@synthesize screenNameType;
@synthesize lastRelatedScreen;

@synthesize isActive;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (self)
        {
            for ( NSString *notification in [self listNotificationInterests] )
            {
                NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                [center addObserver:self selector:@selector(handleNotification:) name:notification object:nil];
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    // GA tracking page
   /* self.trackedViewName = [self getPageName];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:[self getPageName]];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	else
		return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self clearAll];
}

- (void)viewActionAfterTurningBack
{
    
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - progress HUD

- (void)showProgressHUDWithType:(MBProgressHUDMode)type andMessage:(NSString*)message
{
    //Prepare Progress HUD
    if(self.progressHUD.superview)
    {
        [self.progressHUD removeFromSuperview];
        self.progressHUD.delegate = nil;
        self.progressHUD = nil;
    }
    if(type == MBProgressHUDModeCustomView)
    {
        self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SC_PROGRESS_HUD_CHECKED]];
        [self.progressHUD show:YES];
        [self.progressHUD hide:YES afterDelay:0.5];
    }
    else
    {
        self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.progressHUD show:YES];
    }
    self.progressHUD.mode = type;
    self.progressHUD.labelText = message;
    self.progressHUD.progress = 0;
    self.progressHUD.delegate = self;
    [self.view addSubview:self.progressHUD];
    
    
}

- (void)hideProgressHUD
{
    //hide progress HUD
    [self.progressHUD show:NO];
    [self.progressHUD removeFromSuperview];
}

#pragma mark - class methods

- (void)clearAll
{
    [[SCScreenManager getInstance] clearAllHistory];
}

- (NSMutableDictionary*)lastData
{
    return [SCScreenManager getInstance].transitData;
}

- (void)gotoScreen:(SCEnumScreen)screenName data:(NSMutableDictionary *)data
{
    [[SCScreenManager getInstance] gotoScreen:screenName data:data];
}

- (void)presentScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data
{
    [[SCScreenManager getInstance] presentScreen:screenName data:data];

}

- (void)presentScreen:(SCEnumScreen)screenName data:(NSMutableDictionary*)data animated:(BOOL)animated {
    [[SCScreenManager getInstance] presentScreen:screenName data:data animated:animated];
}

- (void)goBack
{
    [self clearAll];
    [[SCScreenManager getInstance] goBack];
}

- (void)dismissPresentScreen
{
    [[SCScreenManager getInstance] dismissCurrentPresentScreenWithAnimated:YES completion:nil];
}

- (void)dismissPresentScreenWithAnimated:(BOOL)animated completion:(void (^)(void))completionBlock
{
    [[SCScreenManager getInstance] dismissCurrentPresentScreenWithAnimated:animated completion:completionBlock];
}


- (void)showLoading
{
    if(!self.loadingView)
        self.loadingView = [[SCLoadingView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width ,self.view.frame.size.height)];
    
    if(!self.loadingView.superview)
        [self.view addSubview:self.loadingView];
    
}

- (void)showLoadingWithFrame:(CGRect)frame
{
    if(!self.loadingView)
    {
        self.loadingView = [[SCLoadingView alloc] initWithFrame:frame];
    }
    if(!self.loadingView.superview)
    {
        [self.view addSubview:self.loadingView];
        [self.loadingView setFrame:frame];
    }
}

- (void)hideLoading
{
    if(self.loadingView)
    {
        if(self.loadingView.superview)
        {
            [self.loadingView removeFromSuperview];
            //self.loadingView = nil;
        }
    }
}

- (NSString *)getPageName {
    switch ([self getCurrentPageType]) {
            default:
            return @"None Screen";
            break;
    }
}

- (SCEnumScreen)getCurrentPageType
{
    return [SCScreenManager getInstance].currentScreen;
}

- (SCViewController *)currentPresentVC
{
    return [SCScreenManager getInstance].currentPresentVC;
}




#pragma mark - class general methods


- (void)showInternetSignalAlert {
  }

- (void)hideInternetSignalAlert {
  }

- (void)SCAlertViewButtonTapped {
    NSLog(@"try again");
}

#pragma mark Check Internet Connection
- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired = YES;
    NSString *statusString = @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Please check your Internet Setting!.";
            connectionRequired = NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            connectionRequired = YES;
            statusString = @"Reachable WWAN";
            break;
        }
        case ReachableViaWiFi:
        {
            connectionRequired = YES;
            statusString= @"Reachable WiFi";
            break;
        }
    }
    if (!connectionRequired) {
        [self showInternetSignalAlert];
    } else {
        [self hideInternetSignalAlert];
    }
}

-(void)setupObserverInternetSignal{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
    internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	[self updateInterfaceWithReachability: internetReach];
}

- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

#pragma mark - notification helpers

- (void)sendNotification:(NSString *)notificationName
{
	[self sendNotification:notificationName body:nil type:nil];
}


- (void)sendNotification:(NSString *)notificationName body:(id)body
{
	[self sendNotification:notificationName body:body type:nil];
}

- (void)sendNotification:(NSString *)notificationName body:(id)body type:(id)type
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	NSMutableDictionary *dic = nil;
	if (body || type) {
		dic = [[NSMutableDictionary alloc] init];
		if (body) [dic setObject:body forKey:@"body"];
		if (type) [dic setObject:type forKey:@"type"];
	}
	NSNotification *n = [NSNotification notificationWithName:notificationName object:self userInfo:dic];
	[center postNotification:n];
}

- (NSArray *)listNotificationInterests
{
    return [NSArray arrayWithObjects: nil];
}

- (void)handleNotification:(NSNotification *)notification
{
    
}

#pragma mark - critercism delegate

- (void)crittercismDidCrashOnLastLoad
{
    NSLog(@"App crashed the last time [%@] was loaded", self.description);
}

#pragma mark - animation

- (void)fadeInWithCompletion:(void (^)(void))completionBlock
{
    self.view.alpha = 0;
    [UIView animateWithDuration:SC_VIEW_ANIMATION_DURATION animations:^
     {
         self.view.alpha = 1;
     }completion:^(BOOL finished)
     {
         completionBlock();
     }];
}

- (void)fadeOutWithCompletion:(void (^)(void))completionBlock
{
    self.view.alpha = 1;
    [UIView animateWithDuration:SC_VIEW_ANIMATION_DURATION animations:^
     {
         self.view.alpha = 0;
     }completion:^(BOOL finished)
     {
         completionBlock();
     }];
}

- (void)zoomInWithCompletion:(void (^)(void))completionBlock
{
    self.view.alpha = 0;
    self.view.transform = CGAffineTransformMakeScale(3, 3);
    
    [UIView animateWithDuration:SC_VIEW_ANIMATION_DURATION animations:^{
        self.view.alpha = 1;
        self.view.transform = CGAffineTransformMakeScale(1, 1);
        
    }completion:^(BOOL finished)
     {
         completionBlock();
     }];
}

- (void)zoomOutWithCompletion:(void (^)(void))completionBlock
{
    self.view.alpha = 1;
    self.view.transform = CGAffineTransformMakeScale(1, 1);
    
    [UIView animateWithDuration:SC_VIEW_ANIMATION_DURATION animations:^{
        self.view.alpha = 0;
        self.view.transform = CGAffineTransformMakeScale(3, 3);
        
    }completion:^(BOOL finished)
     {
         completionBlock();
     }];
}

- (void)moveUpWithCompletion:(void (^)(void))completionBlock
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.superview.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:SC_VIEW_ANIMATION_DURATION animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.superview.frame.size.height - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    }completion:^(BOOL finished)
     {
         completionBlock();
     }];
    
}

- (void)moveDownWithCompletion:(void (^)(void))completionBlock
{
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.superview.frame.size.height - self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView animateWithDuration:SC_VIEW_ANIMATION_DURATION animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.superview.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        
    }completion:^(BOOL finished)
     {
         completionBlock();
     }];
}


@end