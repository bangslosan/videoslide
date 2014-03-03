//
//  SCExporterViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCExporterViewController.h"
#import "SCSlideShowComposition.h"

typedef enum
{
    SCExportAlertNone,
    SCExportAlertReplaceExistFile,
    SCExportAlertNoticeProjectName,
    SCExportAlertExportVideoSuccess,
    SCExportAlertExportVideoFail,
    SCExportAlertProjectSuccess,
    SCExportAlertProjectFail,

}SCExportAlert;

@interface SCExporterViewController () <MBProgressHUDDelegate, SCMediaExporterProtocol, SCProjectExporterProtocol,SCSlideShowCompositionProtocol, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong)  IBOutlet UILabel         *qualityLb;
@property (nonatomic, strong)  IBOutlet UITextField     *titleTf;
@property (nonatomic, strong)  IBOutlet UISwitch        *videoSwitch;
@property (nonatomic, strong)  IBOutlet UISwitch        *projectSwitch;
@property (nonatomic, strong)  UIActionSheet            *actionSheet;

@property (nonatomic, strong)  SCSlideShowComposition   *slideShow;
@property (nonatomic, strong)  SCMediaExporter          *videoExporter;
@property (nonatomic, strong)  SCProjectExporter        *projectExporter;
@property (nonatomic, strong)  MBProgressHUD            *progressHUD;

@property (nonatomic)  BOOL                             exportProjectSucceed;
@property (nonatomic)  BOOL                             exportVideoSucceed;



- (IBAction)onBackBtn:(id)sender;
- (IBAction)onVideoSwitch:(id)sender;
- (IBAction)onProjectSwitch:(id)sender;
- (IBAction)onExportBtn:(id)sender;
- (IBAction)onQualityOption:(id)sender;

- (void)showProgressHUDWithType:(MBProgressHUDMode)type andMessage:(NSString*)message;
- (void)hideProgressHUD;

- (void)exportTocameraRoll;
- (void)exportAsProject;

- (void)startExportMovie;
- (void)startExportProject;


- (void)refreshAndGotoProjectDetail;
- (void)getVideoThumbnail;

@end

@implementation SCExporterViewController

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
    SCSlideShowComposition *temp = [[self lastData] objectForKey:SC_TRANSIT_KEY_SLIDE_SHOW_DATA];
    self.slideShow = [[SCSlideShowComposition alloc] init];
    self.slideShow.slides           = temp.slides;
    self.slideShow.transitions      = temp.transitions;
    self.slideShow.musics           =  temp.musics;
    self.slideShow.audios           = temp.audios;
    self.slideShow.model            = temp.model;
    self.slideShow.isAdvanced       = temp.isAdvanced;
    self.slideShow.name             = temp.name;
    self.slideShow.totalDuration    = temp.totalDuration;
    self.slideShow.videos           = temp.videos;
    self.slideShow.deleteItems      = temp.deleteItems;
    self.slideShow.mediaExportQuality = temp.mediaExportQuality;
    self.slideShow.delegate = self;
    self.titleTf.text = self.slideShow.name;
    
    self.exportProjectSucceed = NO;
    self.exportVideoSucceed = NO;
    [self.titleTf becomeFirstResponder];
    
    //crete action sheet
    NSString *actionSheetTitle = @"Export Quality"; //Action Sheet Title
    NSString *cancelTitle = @"Cancel";
    self.actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles: NSLocalizedString(@"Hight", nil),
                                  NSLocalizedString(@"Medium", nil),
                                  NSLocalizedString(@"Low", nil), nil];
    
    self.qualityLb.text = self.slideShow.mediaExportQuality;
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

#pragma mark - actions

- (IBAction)onBackBtn:(id)sender
{
    //need to clear all temp folder + output video in tmp directory
    if([SCFileManager exist:[SCFileManager URLFromTempWithName:SC_OUTPUT_TEMP_FOLDER]])
    {
        [SCFileManager deleteFileWithURL:[SCFileManager URLFromTempWithName:SC_OUTPUT_TEMP_FOLDER]];
    }
    if([SCFileManager exist:[SCFileManager URLFromTempWithName:[SC_OUTPUT_VIDEO stringByAppendingPathExtension:SC_MOV]]])
    {
        [SCFileManager deleteFileWithURL:[SCFileManager URLFromTempWithName:[SC_OUTPUT_VIDEO stringByAppendingPathExtension:SC_MOV]]];

    }
    [self goBack];
}

- (IBAction)onVideoSwitch:(id)sender
{
    
}

- (IBAction)onProjectSwitch:(id)sender
{
    
}


- (IBAction)onExportBtn:(id)sender
{
    self.exportVideoSucceed = NO;
    self.exportProjectSucceed =  NO;
    self.slideShow.iSOverWrite = NO;
    
    if(self.projectSwitch.isOn)
        [self exportAsProject];
    else
    {
        if(self.videoSwitch.isOn && !self.projectSwitch.isOn)
        {
            [self exportTocameraRoll];
        }
    }
}

- (IBAction)onQualityOption:(id)sender
{
    [self.actionSheet showInView:self.view];
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            self.slideShow.mediaExportQuality = NSLocalizedString(@"Hight", nil);
            break;
        case 1:
            self.slideShow.mediaExportQuality = NSLocalizedString(@"Medium", nil);
            break;
        case 2:
            self.slideShow.mediaExportQuality = NSLocalizedString(@"Low", nil);
            break;
        default:
            break;
    }
    self.qualityLb.text = self.slideShow.mediaExportQuality;

}

#pragma mark - class methods

- (void)showProgressHUDWithType:(MBProgressHUDMode)type andMessage:(NSString*)message
{
    //Prepare Progress HUD
    if(self.progressHUD.superview)
    {
        [self.progressHUD removeFromSuperview];
        self.progressHUD.delegate = nil;
        self.progressHUD = nil;
    }
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD.delegate = self;
    self.progressHUD.mode = type;
    self.progressHUD.labelText = message;
    [self.progressHUD show:YES];
    self.progressHUD.progress = 0;
    [self.view addSubview:self.progressHUD];
    
}

- (void)hideProgressHUD
{
    //hide progress HUD
    [self.progressHUD show:NO];
    [self.progressHUD removeFromSuperview];
}

- (void)startExportMovie
{
    if(!self.exportProjectSucceed)
        [self showProgressHUDWithType:MBProgressHUDModeIndeterminate andMessage:NSLocalizedString(@"processing", nil)];

    if(!self.slideShow.name || self.slideShow.name.length == 0)
    {
        self.slideShow.name = SC_OUTPUT_VIDEO;
    }
    //export final video
    if(self.videoExporter)
    {
        self.videoExporter = nil;
        self.videoExporter.delegate = nil;
    }
    self.videoExporter = [[SCMediaExporter alloc]init];
    self.videoExporter.delegate = self;
    self.videoExporter.needToWriteToCameraRoll = self.videoSwitch.isOn;
    [self.videoExporter exportMediaWithSlideShow:self.slideShow];

}

- (void)startExportProject
{

    [self showProgressHUDWithType:MBProgressHUDModeIndeterminate andMessage:NSLocalizedString(@"processing", nil)];
    //delete the last project with the same name of this project
    NSURL *url = [SCFileManager urlFromDir:[SCFileManager getInstance].projectRootDir withName:self.slideShow.name];
    if(![SCFileManager exist:url])
    {
        url =  [SCFileManager createFolderFromDir:[SCFileManager getInstance].projectRootDir WithName:self.slideShow.name];
    }    
    
    self.slideShow.exportURL = url;
    //export final project
    if(self.projectExporter)
    {
        self.projectExporter = nil;
        self.projectExporter.delegate = nil;
    }
    self.projectExporter = [[SCProjectExporter alloc] init];
    self.projectExporter.delegate = self;
    [self.projectExporter exportProjectWithSlideShow:self.slideShow];
}

- (void)refreshAndGotoProjectDetail
{
    int index = 0;
    for(int i = 0 ; i < [SCFileManager getInstance].slideShows.count ; i++)
    {
        SCSlideShowModel *slideShow = [[SCFileManager getInstance].slideShows objectAtIndex:i];
        if([self.slideShow.name isEqualToString:slideShow.name])
        {
            index = i;
            break;
        }
    }
    
    NSURL *videoURL =  [SCFileManager urlFromDir:[NSURL fileURLWithPath:self.slideShow.model.exportURL] withName:self.slideShow.model.exportVideoName];

    AVAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
	CMTime time = kCMTimeZero;
    NSMutableArray *times = [NSMutableArray array];
    [times addObject:[NSValue valueWithCMTime:time]];

    [imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                         completionHandler:^(CMTime requestedTime,
                                                             CGImageRef cgImage,
                                                             CMTime actualTime,
                                                             AVAssetImageGeneratorResult result,
                                                             NSError *error)
     {
         if(cgImage)
         {
             self.slideShow.thumbnailImg = [[UIImage alloc]initWithCGImage:cgImage];
             if(self.slideShow.thumbnailImg)
             {
                 [SCFileManager writeImageIntoDir:self.slideShow.exportURL image:self.slideShow.thumbnailImg imageName:self.slideShow.model.thumbnailImageName];
             }
         }
         
         dispatch_async(dispatch_get_main_queue(), ^
                        {
                            [[SCScreenManager getInstance] popToScreen:SCEnumProjectDetailScreen data:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:SC_TRANSIT_KEY_SLIDE_SHOW_INDEX]];
                        });
         
     }];

}

- (void)getVideoThumbnail
{
    AVAsset *asset = [AVURLAsset URLAssetWithURL:self.slideShow.exportURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:0
                                         completionHandler:^(CMTime requestedTime,
                                                             CGImageRef cgImage,
                                                             CMTime actualTime,
                                                             AVAssetImageGeneratorResult result,
                                                             NSError *error)
     {
         self.slideShow.thumbnailImg = [UIImage imageWithCGImage:cgImage];
         if(self.slideShow.thumbnailImg)
         {
             [SCFileManager writeImageIntoDir:self.slideShow.exportURL image:self.slideShow.thumbnailImg imageName:self.slideShow.model.thumbnailImageName];
         }

     }];
    
}

#pragma mark - slide show protocol

- (void)prebuildProgressValue:(float)currentValue totalValue:(float)totalValue
{
    if(self.progressHUD)
    {
        self.progressHUD.progress = ((float)currentValue / (float)totalValue);
    }
    
}

#pragma mark - textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - export methods

- (void)exportTocameraRoll
{
    [self startExportMovie];
}

- (void)exportAsProject
{
    if(self.slideShow && self.titleTf.text.length!= 0)
    {
        self.slideShow.name = self.titleTf.text;
        NSURL *projectURL = [SCFileManager urlFromDir:[SCFileManager getInstance].projectRootDir withName:self.slideShow.name];
        if([SCFileManager exist:projectURL])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[NSString stringWithFormat:@"%@ is exist. Do you want to replace ?",self.slideShow.name]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:@"Cancel", nil];
            alertView.tag = SCExportAlertReplaceExistFile;
            [alertView show];
        }
        else
        {
            [self startExportProject];
        }
    }
    else if(self.titleTf.text.length == 0 && self.slideShow)
    {
        [self.titleTf becomeFirstResponder];
    }
}



#pragma mark - export video session delegate

- (void)percentOfExportProgress:(float)percent
{
    self.progressHUD.labelText  = [NSString stringWithFormat:@"%@ %.0f%%",NSLocalizedString(@"exporting", nil),percent * 100];
}


- (void)didFinishPreExportWithSuccess:(BOOL)status
{
    [self hideProgressHUD];
    [self showProgressHUDWithType:MBProgressHUDModeIndeterminate andMessage:NSLocalizedString(@"exporting", nil)];
}

- (void)didFinishExportVideoWithSuccess:(BOOL)status
{
    NSString *message = nil;
    SCExportAlert alertType;
    if(status)
    {
        if(self.exportProjectSucceed)
        {
            if(!self.videoSwitch.isOn && self.projectSwitch.isOn)
            {
                [self refreshAndGotoProjectDetail];
                alertType = SCExportAlertProjectSuccess;
            }
            
            //get thumbnail from video for project thumbnail
        }
    }
    else
    {
        if(self.projectSwitch.isOn)
        {
            NSURL *url = [SCFileManager urlFromDir:[SCFileManager getInstance].projectRootDir withName:self.slideShow.name];

            if([SCFileManager exist:url])
            {
                [SCFileManager deleteFileWithURL:url];
                [[SCFileManager getInstance] updateSlideShows];
            }
            message = @"Export project failed";
            alertType = SCExportAlertProjectFail;

        }
        else if(!self.projectSwitch.isOn && self.videoSwitch.isOn)
        {
            NSLog(@"[Project expoter]  Export Video successfully");
            message = @"Export video failed";
            alertType = SCExportAlertExportVideoFail;
        }
    }
    if(message)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        alertView.tag = alertType;
        [alertView show];
        [self hideProgressHUD];

    }
    
}

- (void)didFinishWriteToLibraryWithSuccess:(BOOL)status
{
    NSString *message = nil;
    SCExportAlert alertType;
    if(status)
    {
        if(self.projectSwitch.isOn && self.videoSwitch.isOn)
        {
            [self refreshAndGotoProjectDetail];
        }
        else if(!self.projectSwitch.isOn && self.videoSwitch.isOn)
        {
            message = @"Export video successfully";
            alertType = SCExportAlertExportVideoSuccess;
        }
    }
    else
    {
        if(!self.projectSwitch.isOn)
        {
            message = @"Failed to save video to camera roll";
            alertType = SCExportAlertNone;
        }
    }
    
    [self hideProgressHUD];
    if(message)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        alertView.tag = alertType;
        [alertView show];
    }
}



#pragma mark - export project  session  delegate

- (void)didFinishExportProjectWithSatus:(BOOL)status
{
    if(status)
    {
        self.exportProjectSucceed = YES;
        //export movie to project directory
        [self startExportMovie];
    }
    else
    {
        NSLog(@"[Project expoter]  Export project failed");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Export to project failed"																	   delegate:self
                                                  cancelButtonTitle:@"Retry"
                                                  otherButtonTitles:nil];
        alertView.tag = SCExportAlertProjectFail;
        //[alertView show];
        
        self.exportProjectSucceed = NO;

    }
}


#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case SCExportAlertReplaceExistFile:
        {
            if(buttonIndex == 0)
            {
                self.slideShow.iSOverWrite = YES;
                [self startExportProject];
            }
            else
            {
                [self.titleTf becomeFirstResponder];
                self.slideShow.name = nil;
            }

        }
        break;
        case SCExportAlertProjectSuccess:
        {
            [self refreshAndGotoProjectDetail];
        }
        break;
            
        default:
            break;
    }
   
}
#pragma mark - clear

- (void)clearAll
{
    [super clearAll];
    self.slideShow = nil;
    
    //clear exporter composition
    if(self.videoExporter)
    {
        self.videoExporter = nil;
        self.videoExporter.delegate = nil;
    }
    
    if(self.projectExporter)
    {
        self.projectExporter.delegate = nil;
        self.projectExporter = nil;
    }
    
    // clear HUD
    if(self.progressHUD.superview)
    {
        [self.progressHUD removeFromSuperview];
    }
    self.progressHUD = nil;
}


@end
