//
//  SCVineAuthenticateViewController.m
//  SlideshowCreator
//
//  Created 12/11/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCVineAuthenticateViewController.h"

@interface SCVineAuthenticateViewController () <UITextFieldDelegate>

@property (nonatomic,strong) IBOutlet UITextField   *usernameTf;
@property (nonatomic,strong) IBOutlet UITextField   *passwordTf;

- (IBAction)onLoginTapped:(id)sender;
- (IBAction)onCancelTapped:(id)sender;

@end

@implementation SCVineAuthenticateViewController
@synthesize delegate = _delegate;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.usernameTf resignFirstResponder];
    [self.passwordTf resignFirstResponder];
    
    return YES;
}

- (IBAction)onLoginTapped:(id)sender {
    [self doVineLogin];
}

- (IBAction)onCancelTapped:(id)sender {
    [self dismissThisViewWithAnimated:NO];
}

- (void)doVineLogin {
    
    [SVProgressHUD showWithStatus:@"Logging Vine..." maskType:SVProgressHUDMaskTypeClear];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.vineapp.com/users/authenticate"]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:@"https://api.vineapp.com/users/authenticate"
                                                      parameters:@{@"username":self.usernameTf.text,
                                                                   @"password":self.passwordTf.text
                                                                   }];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    //[httpClient setDefaultHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [SVProgressHUD dismiss];
        
        id json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                  options:0
                                                    error:nil];
        NSDictionary *dict = (NSDictionary*)json;
        
        [SCSocialManager getInstance].vineManager.vineSessionID = [[dict objectForKey:@"data"] objectForKey:@"key"];
        [[SCSocialManager getInstance].vineManager saveAuthenticate];

        [self dismissThisViewWithAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [SVProgressHUD dismiss];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"That username of password is incorrect."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
    [operation start];
}

- (void)dismissThisViewWithAnimated:(BOOL)animated {
    if (animated) {
        [[SCScreenManager getInstance].rootViewController dismissPresentScreenWithAnimated:YES completion:^{
            [self.delegate didVineLoginSuccess];
        }];
    } else {
        [[SCScreenManager getInstance].rootViewController dismissPresentScreen];
    }
    
}

@end
