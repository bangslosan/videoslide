//
//  SCSharingViewController.m
//  VideoSlide
//
//  Created by Thi Huynh on 2/27/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCSharingViewController.h"

@interface SCSharingViewController ()

@property (nonatomic, strong) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) IBOutlet UIButton *backBtn;
@property (nonatomic, strong) IBOutlet UIButton *fbBtn;
@property (nonatomic, strong) IBOutlet UIButton *vineBtn;


@property (nonatomic, strong) SCSlideShowComposition            *slideShowComposition;


- (IBAction)onNextBtn:(id)sender;
- (IBAction)onBackBtn:(id)sender;
- (IBAction)onFbBtn:(id)sender;
- (IBAction)onVineBtn:(id)sender;

@end

@implementation SCSharingViewController

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

#pragma mark - actions

- (IBAction)onNextBtn:(id)sender
{
    
}

- (IBAction)onBackBtn:(id)sender
{
    [self goBack];
}

- (IBAction)onFbBtn:(id)sender
{
    
}

- (IBAction)onVineBtn:(id)sender
{
    
}



@end
