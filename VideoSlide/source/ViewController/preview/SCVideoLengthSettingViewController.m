//
//  SCVideoLengthSettingViewController.m
//  VideoSlide
//
//  Created by Thi Huynh on 2/26/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCVideoLengthSettingViewController.h"

@interface SCVideoLengthSettingViewController ()

@property (nonatomic, strong) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) IBOutlet UIButton *backBtn;
@property (nonatomic, strong) SCSlideShowComposition *slideShowComposition;



- (IBAction)onNextBtn:(id)sender;
- (IBAction)onBackBtn:(id)sender;

@end

@implementation SCVideoLengthSettingViewController

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
    self.slideShowComposition = [self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_SHOW_DATA];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (void)onNextBtn:(id)sender
{
    if(self.slideShowComposition.slides.count > 0)
        [self gotoScreen:SCEnumPreviewScreen data:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.slideShowComposition, SC_TRANSIT_KEY_SLIDE_SHOW_DATA ,nil]];

}

- (void)onBackBtn:(id)sender
{
    [self goBack];
}


@end
