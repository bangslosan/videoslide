//
//  SCStartViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCStartViewController.h"

@interface SCStartViewController () <SCSlideShowCompositionProtocol, MBProgressHUDDelegate>

@property (nonatomic, strong) IBOutlet UIButton *startBtn;
@property (nonatomic, strong) IBOutlet UIButton *settingBtn;
@property (nonatomic, strong) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) SCPreviewFlow *previewFlowView;
@property (nonatomic, strong) MBProgressHUD             *progressHUD;



@property (nonatomic, strong) SCSlideShowComposition *slideShowComposition;
@property (nonatomic, strong)  NSMutableArray *slides;



- (IBAction)onStartBtn:(id)sender;
- (IBAction)onSettingBtn:(id)sender;
- (IBAction)onNextBtn:(id)sender;
- (void)updateSlideShowDataWith:(NSMutableArray*)slides;


@end

@implementation SCStartViewController

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
    self.nextBtn.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SCFileManager deleteAllFileFromTemp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - actions

- (IBAction)onStartBtn:(id)sender
{
    [self presentScreen:SCEnumPhotoAlbumScreen data:nil animated:YES];
}

- (IBAction)onSettingBtn:(id)sender
{
    
}

- (IBAction)onNextBtn:(id)sender
{
    if(self.slideShowComposition.slides.count > 0)
        [self gotoScreen:SCEnumPreviewScreen data:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.slideShowComposition, SC_TRANSIT_KEY_SLIDE_SHOW_DATA ,nil]];
}

#pragma mark - class methods

- (void)updateSlideShowDataWith:(NSMutableArray *)slides
{
    [self showProgressHUDWithType:MBProgressHUDModeDeterminate andMessage:nil];
    
    if(!self.slideShowComposition)
    {
        self.slideShowComposition = [[SCSlideShowComposition alloc] init];
        self.slideShowComposition.delegate = self;
        //show next/back buton
        self.nextBtn.frame = CGRectMake(self.nextBtn.frame.origin.x,
                                        self.view.frame.size.height,
                                        self.nextBtn.frame.size.width,
                                        self.nextBtn.frame.size.height);
        
        self.nextBtn.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.nextBtn.frame = CGRectMake(self.nextBtn.frame.origin.x,
                                            self.view.frame.size.height - self.nextBtn.frame.size.height,
                                            self.nextBtn.frame.size.width,
                                            self.nextBtn.frame.size.height);

        } completion:^(BOOL finished) {
            
        }];
    }
    [self.slideShowComposition addSlides:slides];
    [self.slideShowComposition getAllPhotoFromAssetWithoutCrop];

}


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
    self.progressHUD.delegate = self;
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

#pragma mark - slide show composition protocol

- (void)numberGotImage:(int)numberImage
{
    NSLog(@" crop progress %0.2f", (float)numberImage / (float)self.slideShowComposition.slides.count);
    if(self.progressHUD)
        self.progressHUD.progress = (float)numberImage / (float)self.slideShowComposition.slides.count;
}

- (void)finishGetAllPhotoFromAsset
{
    [self hideProgressHUD];
    if(!self.previewFlowView)
    {
        self.previewFlowView = [[SCPreviewFlow alloc]initWith:self.slideShowComposition.slides];
        [self.previewFlowView setFrame:CGRectMake(0, 0, self.previewFlowView.frame.size.width, self.previewFlowView.frame.size.height)];
        [self.view addSubview:self.previewFlowView];
        self.previewFlowView.alpha = 0;
        
        [UIView animateWithDuration:0.5 animations:^
         {
             [self.startBtn setCenter:CGPointMake(self.startBtn.center.x,450)];
             [self.startBtn setTransform:CGAffineTransformMakeScale(0.7, 0.7)];
             [self.startBtn setTitle:@"Add more" forState:UIControlStateNormal];

         }
         completion:^(BOOL finished)
         {
             
             [UIView animateWithDuration:0.3 animations:^
              {
                  self.previewFlowView.alpha = 1;
              }
              completion:^(BOOL finished)
             {
                  
              }];
         }
         ];
    }
    else
    {
        //add more slide item to media time line
        [self.previewFlowView updateWithSlides:self.slideShowComposition.slides];
    }
}


#pragma mark - handle notification

- (NSArray *)listNotificationInterests
{
    return [NSArray arrayWithObjects:SCNotificationDidFinishSelectPhotos, nil];
}

- (void)handleNotification:(NSNotification *)notification
{
    if([notification.name isEqualToString:SCNotificationDidFinishSelectPhotos])
    {
        NSLog(@"end selected photos");
        NSMutableArray *slideData = [notification.userInfo objectForKey:@"body"];
        if(slideData.count > 0)
        {
            [self updateSlideShowDataWith:slideData];
        }
    }
}

#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
}

@end
