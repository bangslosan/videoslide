//
//  SCPhotosViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPhotosViewController.h"
#import "SCPhotoPickerViewController.h"
#import <ImageIO/ImageIO.h>
@interface SCPhotosViewController () <SCPhotoPickerViewControllerDelegate, SCItemGridViewProtocol, SCPhotoCaptureViewControllerDelegate, SCSheetMenuDelegate, SCPhotoCropViewControllerDeletate, SCPhotoInstagramViewControllerDelegate, SCPhotoManageViewControllerDelegate> {
    ALAssetsLibrary *library;
}

@property (nonatomic, strong) IBOutlet UIView   *navigationView;
@property (nonatomic, strong) IBOutlet UIView   *itemView;
@property (nonatomic, strong) SCItemGridView    *gridView;
@property (nonatomic, strong) NSMutableArray    *data;
@property (nonatomic, strong) NSMutableArray    *preparingData;
@property (nonatomic, strong) IBOutlet UILabel  *numberOfPhotoSelectedLb;
@property (nonatomic, strong) IBOutlet UIImageView  *vineModeImgView;
@property (nonatomic, strong) IBOutlet UIImageView  *instagramModeImgView;
@property (nonatomic, strong) IBOutlet UIImageView  *customModeImgView;

@property (nonatomic, assign) int indexFullImage;

@property (nonatomic, strong) IBOutlet UILabel  *progressLabel;
@property (nonatomic, strong) IBOutlet SCPhotoCaptureViewController *photoCaptureViewController;
@property (nonatomic, strong) IBOutlet SCPhotoInstagramViewController *photoInstagramViewController;
// context sheet menu
@property (nonatomic, strong) SCSheetMenu           *scSheetMenu;
@property (nonatomic, assign) int                   currentDataIndex;
@property (nonatomic, assign) int                   slideIndex;


- (IBAction)onBackBtn:(id)sender;
- (IBAction)onNextBtn:(id)sender;
- (IBAction)onCameraRollBtn:(id)sender;
- (IBAction)onCameraCaptureBtn:(id)sender;
- (IBAction)onInstagramBtn:(id)sender;

- (void)reloadItemsInGridView;

@end

@implementation SCPhotosViewController
@synthesize scSheetMenu;

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

    self.currentDataIndex = -1;
    self.indexFullImage = 0;
    library = [[ALAssetsLibrary alloc] init];
    
    self.data = [[NSMutableArray alloc]init];
    //init grid view
    self.gridView = [[SCItemGridView alloc] initWith:self.itemView.bounds
                                             andType:SCGridViewTypeVertical
                                   numberItemPerPage:self.data.count];
    [self.gridView setDelegate:self];
    [self.gridView setData:self.data];
    //notice that grid view is using static data
    [self.gridView setIsUsingDynamicData:NO];
    [self.gridView setEnableEditing:YES];
    //add to View
    [self.itemView addSubview:self.gridView];
    
    [self updateSelectedModeState];
    
    self.progressLabel.hidden = YES;

    [self loadSCSheetMenu];
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.indexFullImage = 0;
    self.progressLabel.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewActionAfterTurningBack
{
    [super viewActionAfterTurningBack];
    if([SCSlideShowSettingManager getInstance].slideShowComposition.slides.count > 0)
    {
        [self.data removeAllObjects];
        self.data = nil;
        self.data = [[NSMutableArray alloc] initWithArray:[SCSlideShowSettingManager getInstance].slideShowComposition.slides];
        [self.gridView setData:self.data];
        [[SCSlideShowSettingManager getInstance].slideShowComposition.slides removeAllObjects];
    }
    
    [self updateSelectedModeState];
}


#pragma mark - Sheet Menu
- (void)loadSCSheetMenu {
    // init SCSheetMenu
    self.scSheetMenu = [[SCSheetMenu alloc] initWithFrame:self.view.bounds
                                                  buttons:[NSArray arrayWithObjects:@"Delete", @"Duplicate", @"Crop", nil]
                                             cancelButton:@"Cancel"];
    self.scSheetMenu.delegate = self;
    [self.view addSubview:scSheetMenu];
}

- (void)onTapSheetMenuAtIndex:(int)index {
    switch (index) {
        case 0:
            // Delete
            [self deletePhoto];
            break;
        case 1:
            // Duplicate
            [self duplicatePhoto];
            break;
        case 2:
            // Crop
            [self cropPhoto];
            break;
        default:
            break;
    }
    
    [self.scSheetMenu hide];
}

- (void)onTapSheetCancel {
    [self.scSheetMenu hide];
}

#pragma mark - local methods
- (void)updateSelectedModeState {
    
    int num = self.data.count;
    
    if ((num <= 6) && (num > 0)) {
        self.vineModeImgView.image = [UIImage imageNamed:@"image_photoview_vine_enable.png"];
        self.instagramModeImgView.image = [UIImage imageNamed:@"image_photoview_instagram_enable.png"];
        self.customModeImgView.image = [UIImage imageNamed:@"image_photoview_videorize_enable.png"];
    } else if ((num <= 15) && (num > 6)) {
        self.vineModeImgView.image = [UIImage imageNamed:@"image_photoview_vine_disable.png"];
        self.instagramModeImgView.image = [UIImage imageNamed:@"image_photoview_instagram_enable.png"];
        self.customModeImgView.image = [UIImage imageNamed:@"image_photoview_videorize_enable.png"];
    } else if (num > 15) {
        self.vineModeImgView.image = [UIImage imageNamed:@"image_photoview_vine_disable.png"];
        self.instagramModeImgView.image = [UIImage imageNamed:@"image_photoview_instagram_disable.png"];
        self.customModeImgView.image = [UIImage imageNamed:@"image_photoview_videorize_enable.png"];
    } else if (num == 0) {
        self.vineModeImgView.image = [UIImage imageNamed:@"image_photoview_vine_disable.png"];
        self.instagramModeImgView.image = [UIImage imageNamed:@"image_photoview_instagram_disable.png"];
        self.customModeImgView.image = [UIImage imageNamed:@"image_photoview_videorize_disable.png"];
    }
    
    self.numberOfPhotoSelectedLb.text = [NSString stringWithFormat:@"%@ %@",
                                         (num==0)?@"No":[NSString stringWithFormat:@"%d", num],
                                         ((num==1)||(num==0))?@"Photo":@"Photos"];
}

- (void)deletePhoto
{
    if (self.currentDataIndex < 0) {
        return;
    }
    
    [self.data removeObjectAtIndex:self.currentDataIndex];
    //delete slide composition
    
    [self.gridView resetWithData:self.data];
    [self updateSelectedModeState];
}

- (void)duplicatePhoto {
    if (self.currentDataIndex < 0) {
        return;
    }
    
    SCSlideComposition *currentSlide = (SCSlideComposition*)[self.data objectAtIndex:self.currentDataIndex];
    SCSlideComposition *copySlide = [[SCSlideComposition alloc] init];
    copySlide.image = [currentSlide.image copy];
    copySlide.thumbnailImage = [currentSlide.thumbnailImage copy];
    copySlide.originalImage = [currentSlide.originalImage copy];
    copySlide.assetURL  = [currentSlide.assetURL copy];
    copySlide.isCropped= currentSlide.isCropped;

    
    [self.data insertObject:copySlide atIndex:self.currentDataIndex+1];
    [self.gridView resetWithData:self.data];
    [self updateSelectedModeState];
}

- (void)cropPhoto {
    if (self.currentDataIndex < 0) {
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *cropData = [[NSMutableArray alloc] init];
    [cropData addObject:(SCSlideComposition*)[self.data objectAtIndex:self.currentDataIndex]];
    
    [dict setObject:cropData forKey:SC_TRANSIT_KEY_SLIDE_ARRAY];
    //[dict setObject:[NSNumber numberWithInt:self.currentDataIndex] forKey:SC_TRANSIT_KEY_SLIDE_DATA_INDEX];
    [dict setObject:[NSNumber numberWithInt:0] forKey:SC_TRANSIT_KEY_SLIDE_DATA_INDEX];
    
    [self presentScreen:SCEnumPhotoCropScreen data:dict];
    ((SCPhotoCropViewController*)self.currentPresentVC).delegate = self;
    
    /*
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:(SCSlideComposition*)[self.data objectAtIndex:self.currentDataIndex]
                                                                   forKey:SC_TRANSIT_KEY_SLIDE_DATA];
    [self presentScreen:SCEnumPhotoCropScreen data:dict];
    ((SCPhotoCropViewController*)self.currentPresentVC).delegate = self;
     */
}

#pragma mark - ibactions
- (IBAction)onBackBtn:(id)sender {
    [self goBack];
}

- (IBAction)onNextBtn:(id)sender {
    [self preparingDataToMainView];
}

- (IBAction)onCameraRollBtn:(id)sender {
    /*
    SCPhotoPickerViewController *photoPickerViewController = [[SCPhotoPickerViewController alloc] initWithNibName:@"SCPhotoPickerViewController" bundle:nil];
    photoPickerViewController.delegate = self;
    [self presentViewController:photoPickerViewController animated:YES completion:nil];
     */
    
    //[self presentScreen:SCEnumPhotoAlbumScreen data:nil];
    
    //[self presentScreen:SCEnumPhotoManageScreen data:nil];
    
    [SCPhotoSettingManager getInstance].photoChooseType = SCEnumPhotoChooseTypeMultiple;
    [SCPhotoSettingManager getInstance].albumListType = SCEnumAlbumListTypeNormal;
    
    SCPhotoManageViewController *photoManageViewController = [[SCPhotoManageViewController alloc] initWithNibName:@"SCPhotoManageViewController" bundle:nil];
    photoManageViewController.delegate = self;
    [self presentViewController:photoManageViewController animated:YES completion:nil];
}

- (IBAction)onCameraCaptureBtn:(id)sender {
    
    self.photoCaptureViewController = [[SCPhotoCaptureViewController alloc] initWithNibName:@"SCPhotoCaptureViewController" bundle:nil];
    self.photoCaptureViewController.delegate = self;
    [self presentViewController:self.photoCaptureViewController animated:YES completion:nil];
}

- (IBAction)onInstagramBtn:(id)sender {
    
    [SCPhotoSettingManager getInstance].photoChooseType = SCEnumPhotoChooseTypeMultiple;
    
   /* if ([[SCSocialManager getInstance].instagramManager isInstagramLoggedIn]) {
        [self gotoInstagramViewAnimated:YES];
    } else {
        [SCSocialManager getInstance].instagramManager.loginFor = SCNotificationInstagramDidLogInWhileDismissing;
        [[SCSocialManager getInstance].instagramManager instagramLogIn];
    }*/
}

- (void)gotoInstagramViewAnimated:(BOOL)animated {
    self.photoInstagramViewController = [[SCPhotoInstagramViewController alloc] initWithNibName:@"SCPhotoInstagramViewController" bundle:nil];
    self.photoInstagramViewController.delegate = self;
    [self presentViewController:self.photoInstagramViewController animated:animated completion:nil];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.photoCaptureViewController;
}

#pragma mark - SCPhotoPickerViewControllerDelegate methods
- (void)dismissPhotoPickerWithData:(NSArray *)array {
    /*
    for (int i = 0; i < array.count; i++) {
        SCSlideComposition *slide = (SCSlideComposition*)[array objectAtIndex:i];
        [self.data addObject:slide];
    }
    
    [self.gridView resetWithData:self.data];
    [self updateSelectedModeState];
     */
}

#pragma mark - SCPhotoInstagramViewControllerDelegate methods
- (void)dismissInstagramPhotoViewWithData:(NSArray *)array {
    
    for (int i = 0; i < array.count; i++) {
        SCSlideComposition *slide = (SCSlideComposition*)[array objectAtIndex:i];
        [self.data addObject:slide];
    }
    
    [self.gridView resetWithData:self.data];
    [self updateSelectedModeState];
}

#pragma mark - GridView methods
- (SCItemGridViewCell *)SCitemGridView:(SCItemGridView *)itemGridView cellForItemAtIndex:(int)index
{
    SCPhotoItemView *cell = (SCPhotoItemView*)[itemGridView.gridView dequeueReusableCellWithIdentifier:@"SCItemGridViewCell"];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SCPhotoItemView" owner:self options:nil] objectAtIndex:0];
    }
    
    SCSlideComposition *slideComposition = (SCSlideComposition*)[self.data objectAtIndex:index];
    cell.photoImgView.image = slideComposition.thumbnailImage;
    cell.checkMarkImgView.hidden = YES;
    cell.checkMarkView.hidden = YES;
    return cell;
    
}

- (CGSize)sizeForItemCell
{
    return CGSizeMake(75, 75);
}

- (void)SCitemGridView:(SCItemGridView *)itemGridView loadDataAtfirstTimeWith:(int)numberPage
{
    if(itemGridView.data.count == 0)
    {
        [self.gridView setData:self.data];
    }
}

- (void)SCitemGridView:(SCItemGridView *)itemGridView didSelectItemAtIndex:(int)index withCell:(SCItemGridViewCell *)cell {
    self.currentDataIndex = index;
    [self.scSheetMenu show];
}

#pragma mark - Preparing data for Main Editor view
-(void)preparingDataToMainView {

    // check data is valid
    if (self.data.count <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"You must select as least one photo to create video."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    } else if (self.data.count > 100) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"You cannot select more than 100 photos  to create video."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [SVProgressHUD showWithStatus:NSLocalizedString(@"preparing", nil) maskType:SVProgressHUDMaskTypeClear];

    //self.slideIndex = 0;
    //[self performSelector:@selector(startCropAllPhotos) withObject:nil afterDelay:0.5];
    
    if (self.data.count > 0)
    {
        [SVProgressHUD dismiss];
        [[SCScreenManager getInstance] gotoScreen:SCEnumEditorScreen
                                             data:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   self.data, SC_TRANSIT_KEY_SLIDE_ARRAY,
                                                   nil]];
    }

}

- (BOOL)checkCropStatus
{
    int i= 0;
    for(SCSlideComposition *slideComposition in self.data)
    {
        if(slideComposition.isCropped)
            i++;
        if(i == self.data.count)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)startCropAllPhotos
{
    if(self.data.count > self.slideIndex)
    {
        SCSlideComposition *slide = [self.data objectAtIndex:self.slideIndex];
        if (!slide.isCropped)
        {
            [SCImageUtil cropImageFromURLAsset:slide.assetURL size:SC_CROP_PHOTO_SIZE completionBlock:^(UIImage *result)
            {
                slide.image = result;
                slide.isCropped = YES;
                if([self checkCropStatus])
                    [self finishedLoadFullPhotos];
                else
                {
                    self.slideIndex ++;
                    [self startCropAllPhotos];
                }
            } completionBlock:^{
                [SVProgressHUD dismiss];
            }];
        }
        else
        {
            if([self checkCropStatus])
                [self finishedLoadFullPhotos];
            else
            {
                self.slideIndex ++;
                [self startCropAllPhotos];
            }
        }
    }
}

- (void)finishedLoadFullPhotos {
    
    NSLog(@"%d", self.data.count);
    
    if (self.data.count > 0)
    {
        [SVProgressHUD dismiss];
        [[SCScreenManager getInstance] gotoScreen:SCEnumEditorScreen
                                             data:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   self.data, SC_TRANSIT_KEY_SLIDE_ARRAY,
                                                   nil]];
    }
}

- (void)reloadItemsInGridView
{
    int i = 0;
    for(SCSlideComposition *slideComposition in self.data)
    {
        if(slideComposition.needToRefreshThumbnail)
        {
            if(i < self.gridView.data.count)
                [self.gridView.gridView reloadObjectAtIndex:i animated:NO];
            slideComposition.needToRefreshThumbnail = NO;
        }
        i++;
    }
}
#pragma mark - Photo Capture delegate methods
- (void)photoTakeWithCamera:(SCSlideComposition*)slide
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:slide forKey:SC_TRANSIT_KEY_SLIDE_DATA];
    [self presentScreen:SCEnumPhotoCropScreen data:dict];
    ((SCPhotoCropViewController*)self.currentPresentVC).delegate = self;
    /*
    [self.data addObject:slide];
    [self.gridView resetWithData:self.data];
    [self updateSelectedModeState];
     */
}

#pragma mark - Photo manage delegate methods
- (void)dismissPhotoManageWithData:(NSArray *)array {
    for (int i = 0; i < array.count; i++) {
        SCSlideComposition *slide = (SCSlideComposition*)[array objectAtIndex:i];
        [self.data addObject:slide];
    }
    [self.gridView resetWithData:self.data];
    [self updateSelectedModeState];
}

#pragma mark - Photo Crop delegate methods

- (void)closeCropViewWithData:(NSMutableArray *)data
{
    [self updateSelectedModeState];
    [self reloadItemsInGridView];
}

- (void)closeCropViewWithOnePhoto:(SCSlideComposition *)slideComposition {
    
    [self.data addObject:slideComposition];
    [self updateSelectedModeState];
    [self.gridView resetWithData:self.data];
    //[self reloadItemsInGridView];
}


#pragma mark - Notification for Instagram

- (NSArray *)listNotificationInterests {
    return [NSArray arrayWithObjects:
            SCNotificationInstagramDidLogIn,
            SCNotificationInstagramDidLogInWhileDismissing,
            nil];
}

- (void)handleNotification:(NSNotification *)notification {
    
    // instagram handle notifications
    if ([notification.name isEqualToString:SCNotificationInstagramDidLogIn]) {
        [self finishLoginInstagram];
    }
}

- (void)finishLoginInstagram {
    [self gotoInstagramViewAnimated:NO];
}

- (void)hideUnShowControls {
    self.navigationView.hidden = YES;
    self.itemView.hidden = YES;
}

- (void)showUnShowControls {
    self.navigationView.hidden = NO;
    self.itemView.hidden = NO;
}

#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
    if([SCSlideShowSettingManager getInstance].slideShowComposition)
    {
        [[SCSlideShowSettingManager getInstance].slideShowComposition clearAll];
        [SCSlideShowSettingManager getInstance].slideShowComposition = nil;
    }
    else
    {
        if(self.data.count > 0)
        {
            for(SCSlideComposition *slide in self.data)
            {
                [slide clearAll];
            }
            [self.data removeAllObjects];
        }
        self.data  = nil;
    }
    
    //clear all files from temp dir
    [SCFileManager deleteAllFileFromTemp];
    
    if(self.gridView)
    {
        [self.gridView clearAll];
        self.gridView = nil;
    }
}

@end




