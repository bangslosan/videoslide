//
//  SCPhotoInstagramViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPhotoInstagramViewController.h"

@interface SCPhotoInstagramViewController () <SCItemGridViewProtocol>

@property (nonatomic, strong) IBOutlet UIView   *itemView;
@property (nonatomic, strong) SCItemGridView    *gridView;

@property (nonatomic, strong) NSMutableArray    *downloadPhotoArray;
@property (nonatomic, strong) IBOutlet UILabel  *numOfPhotoSelectedLb;
@property (nonatomic, assign) int               indexDownloaded;
@property (nonatomic, assign) int               totalSelectedToDownload;
@property (nonatomic, assign) BOOL              isLoading;

// loading
@property (nonatomic, strong) IBOutlet UIView                               *loadingView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView              *loadingIndicator;

@property (nonatomic, strong) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) IBOutlet UIButton *backBtn;

- (IBAction)onBackBtn:(id)sender;
- (IBAction)onNextBtn:(id)sender;
@end

@implementation SCPhotoInstagramViewController
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
    
    [self resetUI];
    
   // [self hideLoadingIndicator];
    
    self.indexDownloaded = 0;
    self.totalSelectedToDownload = 0;
    self.isLoading = NO;
    
    //[[SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray removeAllObjects];
    
    self.downloadPhotoArray = [[NSMutableArray alloc] init];
    
 /*   self.gridView = [[SCItemGridView alloc] initWith:self.itemView.bounds
                                             andType:SCGridViewTypeVertical
                                   numberItemPerPage:[SCSocialManager getInstance].instagramManager.instagramPhotoArray.count];
    [self.gridView setDelegate:self];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[SCSocialManager getInstance].instagramManager.instagramPhotoArray];
    [self.gridView setData:array];*/
    
    //notice that grid view is using static data
    [self.gridView setIsUsingDynamicData:YES];
    [self.gridView addPullToRefreshHeader];
    //add to View
    [self.itemView addSubview:self.gridView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self resetUI];
    
    [self loadInstagramAuthenticateStatus];
}

- (void)resetUI {
    
    if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeMultiple) {
        self.nextBtn.hidden = NO;
        self.numOfPhotoSelectedLb.text = @"0 Photos Selected";
    } else if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeSingle) {
        
        if (SC_IS_IPHONE5) {
            float delta = 0;
            if (![SCHelper isIOS7]) {
                delta = 0;
            }
            
//            self.itemView.frame = CGRectMake(self.itemView.frame.origin.x,
//                                             self.itemView.frame.origin.y,
//                                             self.itemView.frame.size.width,
//                                             367);//self.itemView.frame.size.height - 45 - delta);
            
            self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 566);
        }
        
       // [[SCSocialManager getInstance].instagramManager resetSelectedArray];
        self.nextBtn.hidden = YES;
        self.numOfPhotoSelectedLb.text = @"Instagram";
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackBtn:(id)sender
{
   /* if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeMultiple) {
        
        [self dismissViewControllerAnimated:YES
                                 completion:^(){
                                     [[SCSocialManager getInstance].instagramManager resetSelectedArray];
                                     [self.gridView reloadData];
                                 }];
        [self clearAll];
        
    } else if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeSingle) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    */
}

- (IBAction)onNextBtn:(id)sender {
  //  [self doDownloadInstagramPhoto];
}

#pragma mark - Instagram methods
- (void)loadInstagramAuthenticateStatus {
 /*
    // reset selected array

    [[SCSocialManager getInstance].instagramManager populateSelectedArray];
    if ([SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray.count > 0) {
        [self.gridView reloadData];
    }

    
    if ([[SCSocialManager getInstance].instagramManager isInstagramLoggedIn]) {
        
        if ([[SCSocialManager getInstance].instagramManager.currentRequest isEqualToString:SCInstagramRequestPhoto]
            || [[SCSocialManager getInstance].instagramManager.currentRequest isEqualToString:SCInstagramRequestMorePhoto])
        {
            if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeMultiple) {
                [SVProgressHUD showWithStatus:NSLocalizedString(@"loading", nil) maskType:SVProgressHUDMaskTypeClear];
            }
        }
        else {
            [self.gridView reloadData];
        }

    } else {
        [self doInstagramLogIn];
    }*/
}

#pragma mark - Grid View methods
- (SCItemGridViewCell *)SCitemGridView:(SCItemGridView *)itemGridView cellForItemAtIndex:(int)index
{
    SCPhotoItemView *cell = (SCPhotoItemView*)[itemGridView.gridView dequeueReusableCellWithIdentifier:@"SCItemGridViewCell"];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SCPhotoItemView" owner:self options:nil] objectAtIndex:0];
    }
    
  /*  SCInstagramImage *image = (SCInstagramImage*)[[SCSocialManager getInstance].instagramManager.instagramPhotoArray objectAtIndex:index];
    [cell.photoImgView setImageWithURL:[NSURL URLWithString:image.thumbnailURL]];
    
    // display checkmark icon
    NSNumber *selected = [[SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray objectAtIndex:index];
    if ([selected boolValue]) {
        cell.checkMarkView.hidden = NO;
        cell.checkMarkImgView.hidden = NO;
    } else {
        cell.checkMarkView.hidden = YES;
        cell.checkMarkImgView.hidden = YES;
    }*/
    
    return cell;
    
}

- (CGSize)sizeForItemCell
{
    return CGSizeMake(75, 75);
}

/*- (void)SCitemGridView:(SCItemGridView *)itemGridView loadDataAtfirstTimeWith:(int)numberPage
{
    if(itemGridView.data.count == 0)
    {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[SCSocialManager getInstance].instagramManager.instagramPhotoArray];
        [self.gridView setData:array];
    }
}

- (void)SCitemGridView:(SCItemGridView *)itemGridView didSelectItemAtIndex:(int)index withCell:(SCItemGridViewCell *)cell {
    
    if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeMultiple) {
    
        // display checkmark icon
        BOOL selected = [[[SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray objectAtIndex:index] boolValue];
        [[SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:!selected]];
        
        if (selected) {
            ((SCPhotoItemView*)cell).checkMarkView.hidden = YES;
            ((SCPhotoItemView*)cell).checkMarkImgView.hidden = YES;
        } else {
            ((SCPhotoItemView*)cell).checkMarkView.hidden = NO;
            ((SCPhotoItemView*)cell).checkMarkImgView.hidden = NO;
            
        }
        
        [self updateNumberPhotoSelected];
            
        
    } else if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeSingle) {
        
        BOOL selected = [[[SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray objectAtIndex:index] boolValue];
        [[SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:!selected]];
        
        [self doDownloadInstagramPhoto];
    }

}

- (void)SCitemGridView:(SCItemGridView*)itemGridView loadMoreItemWith:(int)currentPage numberItem:(int)number {
    [self loadMorePhotoInstagram];
}

- (void)SCitemGridView:(SCItemGridView *)itemGridView refreshDataWith:(int)numberPage {
    [self doRefreshInstagramPhoto];
}

- (void)updateNumberPhotoSelected {
    
    int num = 0;
    for (int i = 0; i < [SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray.count; i++) {
        BOOL selected = [[[SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray objectAtIndex:i] boolValue];
        if (selected) {
            num++;
        }
    }
    
    self.numOfPhotoSelectedLb.text = [NSString stringWithFormat:@"%@ %@ Selected",
                                      (num==0)?@"No":[NSString stringWithFormat:@"%d", num],
                                      ((num==1)||(num==0))?@"Photo":@"Photos"];
}


#pragma mark - Download photos from Instagram
- (void)doDownloadInstagramPhoto {
    
    self.indexDownloaded = 0;

    for (int i = 0; i < [SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray.count; i++) {
        BOOL selected = [[[SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray objectAtIndex:i] boolValue];
        if (selected) {
            self.totalSelectedToDownload++;
        }
    }
    
    if (self.totalSelectedToDownload <= 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You should select as least one photo to download." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }

    [SVProgressHUD showWithStatus:NSLocalizedString(@"download_insta_photos", nil) maskType:SVProgressHUDMaskTypeClear];
    
    [self.downloadPhotoArray removeAllObjects];
    
    for (int i = 0; i < [SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray.count; i++) {
        BOOL selected = [[[SCSocialManager getInstance].instagramManager.selectedInstagramPhotoArray objectAtIndex:i] boolValue];
        if (selected) {
            
            SCInstagramImage *instagram = (SCInstagramImage*)[[SCSocialManager getInstance].instagramManager.instagramPhotoArray objectAtIndex:i];
            
            NSOperationQueue *queue = [NSOperationQueue new];
            NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                    selector:@selector(downloadPhoto:)
                                                                                      object:instagram];
            [queue addOperation:operation];
        }
    }
}

- (void)downloadPhoto:(SCInstagramImage*)instagram {
    
    NSURL *thumbnailURL = [NSURL URLWithString:instagram.thumbnailURL];
    NSURL *imageURL     = [NSURL URLWithString:instagram.standardURL];
    
    NSData *thumbnailData   = [NSData dataWithContentsOfURL:thumbnailURL];
    NSData *imageData       = [NSData dataWithContentsOfURL:imageURL];

    UIImage *thumbnail  = [UIImage imageWithData:thumbnailData];
    UIImage *image      = [UIImage imageWithData:imageData];

    
    
    SCSlideComposition *slide = [[SCSlideComposition alloc] initWithImage:[image resizedImageWithMinimumSize:SC_CROP_PHOTO_SIZE]
                                                            withThumbnail:thumbnail
                                                        withOriginalImage:image];
    slide.isCropped = YES;
    
    image = nil;
    imageData = nil;
    thumbnail = nil;
    thumbnailData = nil;
    
    [self.downloadPhotoArray addObject:slide];
    
    [self performSelectorOnMainThread:@selector(finishedLoadImage) withObject:nil waitUntilDone:YES];

}

- (void)finishedLoadImage {
    
    self.indexDownloaded++;
    
    if (self.indexDownloaded == self.totalSelectedToDownload)
    {
        
        
        [SVProgressHUD dismiss];
        
        if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeMultiple) {
         
            if ([self.delegate respondsToSelector:@selector(dismissInstagramPhotoViewWithData:)]) {
                [self.delegate dismissInstagramPhotoViewWithData:self.downloadPhotoArray];
            }
            
            [self dismissViewControllerAnimated:YES
                                     completion:^(){
                                         [[SCSocialManager getInstance].instagramManager resetSelectedArray];
                                         [self.gridView reloadData];
                                     }];
            [self clearAll];
            
        } else if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeSingle) {
            
            [[SCSocialManager getInstance].instagramManager resetSelectedArray];
            
            SCSlideComposition *slideComposition = (SCSlideComposition*)[self.downloadPhotoArray objectAtIndex:0];
            
            if ([self.delegate respondsToSelector:@selector(dismissPhotoPickerWithSlideComposition:)]) {
                [self.delegate dismissPhotoPickerWithSlideComposition:slideComposition];
            }
            
        }
        
        
    }
    
}


- (void)loadMorePhotoInstagram {

    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;

    [[SCSocialManager getInstance].instagramManager requestMoreInstagramPhoto];
}

- (void)showLoadingIndicator {
    
    [self.view bringSubviewToFront:self.loadingView];
    
    self.loadingView.hidden = NO;
    [self.loadingIndicator startAnimating];
}

- (void)hideLoadingIndicator {
    self.loadingView.hidden = YES;
    [self.loadingIndicator stopAnimating];
}

#pragma mark - local Instagram methods
- (void)doInstagramLogIn {
    [[SCSocialManager getInstance].instagramManager instagramLogIn];
}

- (void)doInstagramLogOut {
    [[SCSocialManager getInstance].instagramManager instagramLogOut];
}

- (void)doRefreshInstagramPhoto {
    self.isLoading = YES;
    [[SCSocialManager getInstance].instagramManager.instagramPhotoArray removeAllObjects];
    [[SCSocialManager getInstance].instagramManager requestInstagramPhotoInBackground];
}

- (void)instagramDidLogIn {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"loading", nil) maskType:SVProgressHUDMaskTypeClear];
}

- (void)instagramDidLogout {

}

- (void)instagramSessionInvalidated {
    [SVProgressHUD dismiss];
}

- (void)instagramRequestPhotoDone {
    
    [SVProgressHUD dismiss];
    
    [self hideLoadingIndicator];
    
    self.isLoading = NO;
    
    [self.gridView resetFramePosition];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[SCSocialManager getInstance].instagramManager.instagramPhotoArray];
    [self.gridView setData:array];
}

- (void)instagramRequestMorePhotoDone {
    
    [self hideLoadingIndicator];
    self.isLoading = NO;
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[SCSocialManager getInstance].instagramManager.instagramPhotoArray];
    [self.gridView loadMoreItem:array];
}

- (void)instagramRequestMorePhotoNotDone {
    self.isLoading = NO;
    self.gridView.isInLoadingProgress = NO;
}

- (void)instagramRequestMorePhotoFailed {
    [self hideLoadingIndicator];
    self.isLoading = NO;
    
    [self.gridView parseIsInLoadingProgress:NO];
 
    NSMutableArray *array = [NSMutableArray arrayWithArray:[SCSocialManager getInstance].instagramManager.instagramPhotoArray];
    [self.gridView setData:array];
}

#pragma mark - notification section
- (NSArray *)listNotificationInterests {
    return [NSArray arrayWithObjects:
            SCNotificationInstagramDidLogIn,
            SCNotificationInstagramDidLogOut,
            SCNotificationInstagramDidLoadPhoto,
            SCNotificationInstagramDidLoadMorePhoto,
            SCNotificationInstagramDidFailedLoadMorePhoto,
            SCNotificationInstagramDidLoadMorePhotoFailed,
            nil];
}

- (void)handleNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:SCNotificationInstagramDidLogIn]) {
        [self instagramDidLogIn];
    }
    else if ([notification.name isEqualToString:SCNotificationInstagramDidLogOut]) {
        [self instagramDidLogout];
    }
    else if ([notification.name isEqualToString:SCNotificationInstagramDidLoadPhoto]) {
        [self instagramRequestPhotoDone];
    }
    else if ([notification.name isEqualToString:SCNotificationInstagramDidLoadMorePhoto]) {
        [self instagramRequestMorePhotoDone];
    }
    else if ([notification.name isEqualToString:SCNotificationInstagramDidLoadMorePhotoFailed]) {
        [self instagramRequestMorePhotoNotDone];
    }
    else if ([notification.name isEqualToString:SCNotificationInstagramDidFailedLoadMorePhoto]) {
        [self instagramRequestMorePhotoFailed];
    }
}

#pragma - mark
- (void)clearAll
{
    [super clearAll];
    self.delegate = nil;
    if(self.gridView)
    {
        [self.gridView clearAll];
        self.gridView = nil;
    }
    
    self.delegate = nil;
}
 
 */
@end
