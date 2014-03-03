//
//  SCInstagramAuthenticateViewController.m
//  SlideshowCreator
//
//  Created 11/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCInstagramAuthenticateViewController.h"

@interface SCInstagramAuthenticateViewController ()

@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)onCancelBtn:(id)sender;
- (void)showloadingIndicator;
- (void)hideloadingIndicator;
@end

@implementation SCInstagramAuthenticateViewController
@synthesize webView;
@synthesize delegate;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [NRGramKit loginInWebView:self.webView
         loginLoadingCallback:^(BOOL loading)
     {
         //you can show a spinner while the webview is loading
         if (loading) {
             [self showloadingIndicator];
         } else {
             [self hideloadingIndicator];
         }
         
     }
     
     finishedCallback:^(IGUser* user,NSString* error)
     {
         if (user.username) {
             
             [self hideloadingIndicator];
             
             [[SCScreenManager getInstance].rootViewController dismissPresentScreenWithAnimated:YES completion:^{
                 [self.delegate dismissAuthenticatedInstagram];
             }];
             
         }
         // yay - you are now authenticated, NRGramKit remembers the credentials
         //NSLog(@"NEWINSTA: %@: %d", user.username, [user.media_count integerValue]);
         
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onCancelBtn:(id)sender {
    [[SCScreenManager getInstance].rootViewController dismissPresentScreen];
}

- (void)showloadingIndicator {
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
}

- (void)hideloadingIndicator {
    self.loadingIndicator.hidden = YES;
    [self.loadingIndicator stopAnimating];
}

@end
