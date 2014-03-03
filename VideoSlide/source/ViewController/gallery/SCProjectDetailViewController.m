//
//  SCProjectDetailViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCProjectDetailViewController.h"

@interface SCProjectDetailViewController () <SCItemGridViewProtocol, MBProgressHUDDelegate, SCSheetMenuDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet SCView *itemView;
@property (nonatomic, strong) IBOutlet UIView *toolBarView;
@property (nonatomic, strong) IBOutlet UILabel *headerLb;

@property (nonatomic, strong) SCItemGridView *gridView;
@property (nonatomic, strong) NSMutableArray *slideShowData;
@property (nonatomic, strong) NSMutableArray *thumbnails;

@property (nonatomic, strong) MBProgressHUD  *progressHUD;
@property (nonatomic, strong) SCSheetMenu    *scSheetMenu;

@property (nonatomic)         int             currentIndex;
@property (nonatomic)         BOOL            backFromLastPage;


- (IBAction)onBackBtn:(id)sender;

- (IBAction)onShareBtn:(id)sender;
- (IBAction)onUploadBtn:(id)sender;
- (IBAction)onEditBtn:(id)sender;
- (IBAction)onDeleteBtn:(id)sender;

- (void)updateGalleryData;
- (void)updateHeaderLb;
- (void)showProgressHUDWithType:(MBProgressHUDMode)type andMessage:(NSString*)message;
- (void)hideProgressHUD;
- (void)loadAllSlideShowDataWithSuccessHandler:(void (^)(void))completionBlock;
- (void)stopPlayBack;
@end

@implementation SCProjectDetailViewController

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
    [self loadSheetMenu];
    self.gridView = [[SCItemGridView alloc] initWith:self.itemView.bounds
                                             andType:SCGridViewTypeLargeHorizontal
                                   numberItemPerPage:self.slideShowData.count];
    //notice that grid view is using static data
    [self.gridView setIsUsingDynamicData:NO];
    //add to View
    [self.itemView addSubview:self.gridView];
    self.backFromLastPage = NO;
    if([SCScreenManager getInstance].lastScreen == SCEnumGalleryScreen)
    {
        self.slideShowData = [self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_SHOW_MODEL_ARRAY_DATA];
        self.thumbnails   = [self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_SHOW_THUMBNAIL_ARRAY];
        self.currentIndex   =  ((NSNumber*)[self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_SHOW_INDEX]).intValue;
        self.headerLb.text  = [NSString stringWithFormat:@"%d of %d", self.currentIndex + 1,self.slideShowData.count];
        // Do any additional setup after loading the view from its nib.
        [self.gridView setDelegate:self];
        [self.gridView.gridView setContentOffset:CGPointMake(self.currentIndex * self.itemView.frame.size.width, 0)];

    }
    else if([SCScreenManager getInstance].lastScreen == SCEnumExportScreen)
    {
        [self.gridView setDelegate:self];
        self.currentIndex   =  ((NSNumber*)[self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_SHOW_INDEX]).intValue;
        [self updateGalleryData];
    }
  
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
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopPlayBack];
}
- (void)viewActionAfterTurningBack
{
    [super viewActionAfterTurningBack];
    self.backFromLastPage = YES;
    [self updateGalleryData];
}

- (void)updateGalleryData
{
    [self.gridView setHidden:YES];
    [self.itemView showLoading];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.slideShowData = [SCFileManager getInstance].slideShows;
        if(self.slideShowData.count == 0)
        {
            [[SCFileManager getInstance] updateSlideShows];
            self.slideShowData = [SCFileManager getInstance].slideShows;
        }
        if(self.thumbnails.count > 0)
        {
            [self.thumbnails removeAllObjects];
        }
        self.thumbnails = nil;
        self.thumbnails = [[NSMutableArray alloc] init];
        
        for(SCSlideShowModel* slideShowModel in self.slideShowData)
        {
            //get thumbnails array for slideshow item
            NSURL *thumbnailURL = [SCFileManager urlFromDir:[NSURL fileURLWithPath:slideShowModel.exportURL] withName:slideShowModel.thumbnailImageName];
            if([SCFileManager exist:thumbnailURL])
            {
                UIImage *image = [UIImage imageWithContentsOfFile:thumbnailURL.path];
                [self.thumbnails addObject:image];
            }
            else
            {
                [self.thumbnails addObject:[[UIImage alloc]init]];
            }
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            //set data for grid view
            [self.itemView hideLoading];
            [self.gridView setHidden:NO];
            [self.gridView setData:self.slideShowData];
            self.gridView.alpha = 0;
            [UIView animateWithDuration:0.3 animations:^{
                self.gridView.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
            if(self.backFromLastPage)
            {
                [self updateHeaderLb];
                if(self.currentIndex  >= 0 && self.currentIndex  < self.slideShowData.count)
                {
                    [self.gridView.gridView reloadObjectAtIndex:self.currentIndex  animated:NO];
                }
            }
            else
            {
                [self.gridView.gridView setContentOffset:CGPointMake(self.currentIndex * self.itemView.frame.size.width, 0)];
                self.headerLb.text = [NSString stringWithFormat:@"%d of %d", self.currentIndex + 1,self.slideShowData.count];
            }
            
        });
    });

}

- (void)stopPlayBack
{
    for(int i=0 ; i < self.slideShowData.count ; i++ )
    {
        SCGalleryDetailItemCell *cell = (SCGalleryDetailItemCell*)[self.gridView.gridView cellForItemAtIndex:i];
        [cell stopVideo];
    }

}

#pragma mark - Sheet Menu

- (void)loadSheetMenu {
    self.scSheetMenu = [[SCSheetMenu alloc] initWithFrame:self.view.bounds
                                                   images:[NSArray arrayWithObjects:
                                                           @"icon_projectdetail_save_to_photo.png",
                                                           @"icon_setting_email.png",
                                                           @"icon_setting_imessage.png",
                                                           @"icon_setting_facebook.png",
                                                           @"icon_setting_youtube.png",
                                                           @"icon_setting_vine.png",
                                                           nil]
                                                  buttons:[NSArray arrayWithObjects:
                                                           @"Save to Camera Rool",
                                                           @"Email",
                                                           @"iMessage",
                                                           @"Facebook",
                                                           @"Youtube",
                                                           @"Vine",
                                                           nil]
                                             cancelButton:@"Cancel"];
    self.scSheetMenu.delegate = self;
    [self.view addSubview:self.scSheetMenu];
}

- (void)onTapSheetMenuAtIndex:(int)index {
    switch (index) {
        case SCSheetMenuShareCameraRoll:
            [self cameraRollSave];
            break;
        case SCSheetMenuShareEmail:
            [self emailSharing];
            break;
        case SCSheetMenuShareiMessage:
            [self iMessageSharing];
            break;
        case SCSheetMenuShareFacebook:
            [self facebookSharing];
            break;
        case SCSheetMenuShareYoutube:
            [self youtubeSharing];
            break;
        case SCSheetMenuShareVine:
            [self vineSharing];
            break;
        default:
            break;
    }
    
    [self.scSheetMenu hide];
}

- (void)onTapSheetCancel {
    [self.scSheetMenu hide];
}

#pragma mark - ibactions

- (IBAction)onBackBtn:(id)sender
{
    [self goBack];
}

- (IBAction)onShareBtn:(id)sender {
    [self stopPlayBack];
    [self.scSheetMenu show];
}

- (IBAction)onUploadBtn:(id)sender
{
    [self stopPlayBack];
    [[SCScreenManager getInstance] presentScreen:SCEnumUploadManagerScreen data:nil];
}

- (IBAction)onEditBtn:(id)sender
{
    [self stopPlayBack];
    if(self.currentIndex < self.slideShowData.count)
    {
        SCSlideShowModel *slideShow = [self.slideShowData objectAtIndex:self.currentIndex];
        if(slideShow)
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:slideShow,SC_TRANSIT_KEY_SLIDE_SHOW_COMPOSITION_MODEL, nil];
            [self gotoScreen:SCEnumEditorScreen data:dict];
        }
    }
}

- (IBAction)onDeleteBtn:(id)sender
{
    [self stopPlayBack];
    if(self.currentIndex < self.slideShowData.count)
    {
        UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Project" message:@"Are you sure ?" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        [deleteAlert show];
    }
}


#pragma mark - class methods

- (void)loadAllSlideShowDataWithSuccessHandler:(void (^)(void))completionBlock
{
    
}

- (void)updateHeaderLb
{
    self.currentIndex = (int)(self.gridView.gridView.contentOffset.x / self.view.frame.size.width );
    if(self.currentIndex < 0)
        self.currentIndex = 0;
    self.headerLb.text = [NSString stringWithFormat:@"%d of %d", self.currentIndex + 1,self.slideShowData.count];
}

#pragma mark - item grid view

- (void)SCitemGridView:(SCItemGridView *)itemGridView loadDataAtfirstTimeWith:(int)numberPage
{
    if(itemGridView.data.count == 0)
    {
        [self.gridView setData:self.slideShowData];
    }
}

- (SCItemGridViewCell *)SCitemGridView:(SCItemGridView *)itemGridView cellForItemAtIndex:(int)index
{
    SCGalleryDetailItemCell *cell = (SCGalleryDetailItemCell*)[itemGridView.gridView dequeueReusableCellWithIdentifier:@"SCGalleryDetailItemCell"];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SCGalleryDetailItemCell" owner:self options:nil] objectAtIndex:0];
    }
    
    SCSlideShowModel *slideShow = (SCSlideShowModel*)[self.slideShowData objectAtIndex:index];
    //set slide show info here
    if(slideShow)
    {
        UIImage *image = [self.thumbnails objectAtIndex:index];
        [cell updateWithData:slideShow thumbnail:image];
    }
    
    return cell;
    
}

- (CGSize)sizeForItemCell
{
    return SC_PROJECT_DETAIL_ITEM_SIZE;
}


- (void)didGotoPage:(float)x yValue:(float)y
{
    [self updateHeaderLb];
    [self stopPlayBack];
}

- (void)startScroll:(float)x yValue:(float)y
{
    [self stopPlayBack];
}

#pragma mark -  MBProgress HUD

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

#pragma mark - Sharing
- (void)cameraRollSave {
    SCSlideShowModel *selectedSlideShow = [self.slideShowData objectAtIndex:self.currentIndex];
    NSURL *url = [SCFileManager urlFromDir:[NSURL fileURLWithPath:selectedSlideShow.exportURL] withName:[selectedSlideShow.name stringByAppendingPathExtension:SC_MOV]];
    
    if ([SCFileManager exist:url]) {
        [self writeExportedVideoToAssetsLibrary:url];
    }
}

- (void)emailSharing {
    SCSlideShowModel *selectedSlideShow = [self.slideShowData objectAtIndex:self.currentIndex];
    NSURL *url = [SCFileManager urlFromDir:[NSURL fileURLWithPath:selectedSlideShow.exportURL] withName:[selectedSlideShow.name stringByAppendingPathExtension:SC_MOV]];
    
    if ([SCFileManager exist:url]) {
      //  [[SCSocialManager getInstance].emailManager sendEmailWithDataURL:url title:selectedSlideShow.name];
    }
}

- (void)iMessageSharing {
    SCSlideShowModel *selectedSlideShow = [self.slideShowData objectAtIndex:self.currentIndex];
    NSURL *url = [SCFileManager urlFromDir:[NSURL fileURLWithPath:selectedSlideShow.exportURL] withName:[selectedSlideShow.name stringByAppendingPathExtension:SC_MOV]];
    
    if ([SCFileManager exist:url]) {
      //  [[SCSocialManager getInstance].messageManager sendiMessageWithDataURL:url];
    }
}

- (void)facebookSharing {
   /* if ([[SCSocialManager getInstance].facebookManager isFacebookLoggedIn]) {
        [self doFacebookSharing];
    } else {
        [SCSocialManager getInstance].facebookManager.loginForString = SCNotificationFacebookDidLogInForShareVideo;
        [[SCSocialManager getInstance].facebookManager facebookLogIn];
    }*/
}

- (void)youtubeSharing {
    
   /* if ([[SCSocialManager getInstance].youtubeManager isYoutubeLoggedIn]) {
        [self doYoutubeSharing];
    } else {
        [SCSocialManager getInstance].youtubeManager.loginForString = SCNotificationYoutubeDidLogInForUpload;
        [[SCSocialManager getInstance].youtubeManager youtubeLogIn];
    }*/
}

- (void)vineSharing {
    
    if ([[SCSocialManager getInstance].vineManager isVineLoggedIn]) {
        [self doVineSharing];
    } else {
        [SCSocialManager getInstance].vineManager.loginForString = SCNotificationVineDidLogInForUpload;
        [[SCSocialManager getInstance].vineManager login];
    }
}

- (void)doYoutubeSharing {
    
    SCSlideShowModel *selectedSlideShow = [self.slideShowData objectAtIndex:self.currentIndex];
    NSURL *url = [SCFileManager urlFromDir:[NSURL fileURLWithPath:selectedSlideShow.exportURL]
                                  withName:[selectedSlideShow.name stringByAppendingPathExtension:SC_MOV]];
    //url.path
    SCUploadObject *uploadObject = [[SCUploadObject alloc] init];
    uploadObject.videoURL = url;
    uploadObject.fileName = selectedSlideShow.name;
    uploadObject.uploadType = SCUploadTypeYoutube;
    uploadObject.uploadStatus = SCUploadStatusUploading;
    
    // check upload duplicated
    if ([SCUploadUtil isUploadDuplicated:uploadObject uploadType:SCUploadTypeYoutube])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This video has been uploaded before. You cannot upload it again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [uploadObject upload];
    
    //[[SCSocialManager getInstance].allUploadItems addObject:uploadObject];
    
    if (uploadObject.uploadType == SCUploadTypeYoutube) {
        //[[SCSocialManager getInstance].youtubeManager.uploadArray addObject:uploadObject];
    }
    
    // call Upload Manager view
    [[SCScreenManager getInstance] presentScreen:SCEnumUploadManagerScreen data:nil];
}

- (void)doFacebookSharing {
    
    SCSlideShowModel *selectedSlideShow = [self.slideShowData objectAtIndex:self.currentIndex];
    NSURL *url = [SCFileManager urlFromDir:[NSURL fileURLWithPath:selectedSlideShow.exportURL]
                                  withName:[selectedSlideShow.name stringByAppendingPathExtension:SC_MOV]];
    //url.path
    SCUploadObject *uploadObject = [[SCUploadObject alloc] init];
    uploadObject.videoURL = url;
    uploadObject.fileName = selectedSlideShow.name;
    uploadObject.uploadType = SCUploadTypeFacebook;
    uploadObject.uploadStatus = SCUploadStatusUploading;
    
    // check upload duplicated
    if ([SCUploadUtil isUploadDuplicated:uploadObject uploadType:SCUploadTypeFacebook])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This video has been uploaded before. You cannot upload it again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [uploadObject facebookUpload];
    
    if (uploadObject.uploadType == SCUploadTypeFacebook) {
        [[SCSocialManager getInstance].facebookManager.uploadArray addObject:uploadObject];
    }
    
    // call Upload Manager view
    [[SCScreenManager getInstance] presentScreen:SCEnumUploadManagerScreen data:nil];
}

- (void)doVineSharing {
    
    SCSlideShowModel *selectedSlideShow = [self.slideShowData objectAtIndex:self.currentIndex];
    
    if (selectedSlideShow.duration > 6.0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"Cannot upload video with more than 6 seconds duration."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    int index = [[SCFileManager getInstance].slideShows indexOfObject:selectedSlideShow];
    NSURL *projectURL = [[SCFileManager getInstance].projects objectAtIndex:index];
    NSURL *vineVideoURL = [SCFileManager urlFromDir:projectURL withName:@"vine.mp4"];
    NSURL *url = [SCFileManager urlFromDir:[NSURL fileURLWithPath:selectedSlideShow.exportURL]
                                  withName:[selectedSlideShow.name stringByAppendingPathExtension:SC_MOV]];
    //url.path
    SCUploadObject *uploadObject = [[SCUploadObject alloc] init];
    
    uploadObject.videoURL = url;
    uploadObject.vineOutputURL = vineVideoURL;
    
    uploadObject.fileName = selectedSlideShow.name;
    uploadObject.uploadType = SCUploadTypeVine;
    uploadObject.uploadStatus = SCUploadStatusUploading;
    
    // check upload duplicated
    if ([SCUploadUtil isUploadDuplicated:uploadObject uploadType:SCUploadTypeVine])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This video has been uploaded before. You cannot upload it again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [uploadObject vineUpload];
    
    if (uploadObject.uploadType == SCUploadTypeVine) {
        [[SCSocialManager getInstance].vineManager.uploadArray addObject:uploadObject];
    }
    
    // call Upload Manager view
    [[SCScreenManager getInstance] presentScreen:SCEnumUploadManagerScreen data:nil];

}

#pragma marl - Save to camera roll
- (void)writeExportedVideoToAssetsLibrary:(NSURL*)exportURL
{
    [self showProgressHUDWithType:MBProgressHUDModeDeterminate andMessage:NSLocalizedString(@"saving", nil)];
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportURL])
    {
		[library writeVideoAtPathToSavedPhotosAlbum:exportURL completionBlock:^(NSURL *assetURL, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                [self hideProgressHUD];
                                if (!error)
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Saved to camera roll." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alert show];
                                }
                                else
                                {
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot save to camera roll. Please try again later." delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil];
                                    [alert show];
                                }
                                
                            });
         }];
	}
    else
    {
		NSLog(@"Video could not be exported to assets library.");
	}
}

#pragma mark - alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) //approve to delete selected project
    {
        SCSlideShowModel *slideShow = [self.slideShowData objectAtIndex:self.currentIndex];
        if([SCFileManager deleteFileWithURL:[NSURL fileURLWithPath:slideShow.exportURL]])
        {
            [slideShow clearAll];
            [self.slideShowData removeObjectAtIndex:self.currentIndex];
            [self.thumbnails removeObjectAtIndex:self.currentIndex];
            slideShow = nil;
            [self.gridView setData:self.slideShowData];
            //update label
            [self updateHeaderLb];
            if(self.slideShowData.count == 0)
            {
                [self onBackBtn:nil];
            }
        }
    }
}

#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
    if(self.progressHUD)
    {
        self.progressHUD.delegate = self;
    }
    self.thumbnails = nil;
    
    if(self.gridView)
    {
        [self.gridView clearAll];
    }
}

#pragma mark - notification section
- (NSArray *)listNotificationInterests {
    return [NSArray arrayWithObjects:
            SCNotificationYoutubeDidLogInForUpload,
            SCNotificationFacebookDidLogInForShareVideo,
            SCNotificationVineDidLogInForUpload,
            nil];
}

- (void)handleNotification:(NSNotification *)notification {
    
    // instagram handle notifications
    if ([notification.name isEqualToString:SCNotificationYoutubeDidLogInForUpload]) {
        [self doYoutubeSharing];
    }
    else if ([notification.name isEqualToString:SCNotificationFacebookDidLogInForShareVideo]) {
        [self doFacebookSharing];
    }
    else if ([notification.name isEqualToString:SCNotificationVineDidLogInForUpload]) {
        [self doVineSharing];
    }
}



@end
