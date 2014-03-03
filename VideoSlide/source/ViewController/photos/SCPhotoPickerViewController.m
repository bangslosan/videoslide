//
//  SCPhotoPickerViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPhotoPickerViewController.h"

@interface SCPhotoPickerViewController () <SCItemGridViewProtocol> {
    ALAssetsLibrary *library;
    NSMutableArray *imageArray;
    NSMutableArray *mutableArray;
    
}

@property (nonatomic, strong) IBOutlet UIView   *itemView;
@property (nonatomic, strong) SCItemGridView    *gridView;
@property (nonatomic, strong) NSMutableArray    *selectedArray;
@property (nonatomic, strong) NSMutableArray    *orderSelectedArray;
@property (nonatomic, strong) IBOutlet UILabel  *numOfPhotoSelectedLb;
@property (nonatomic, assign) int               indexDownloaded;

@property (nonatomic, strong) IBOutlet UIButton *nextBtn;

- (IBAction)onBackBtn:(id)sender;
- (IBAction)onNextBtn:(id)sender;

@end

static int count = 0;

@implementation SCPhotoPickerViewController
@synthesize delegate;
@synthesize assetGroup;
@synthesize orderSelectedArray = _orderSelectedArray;
@synthesize data = _data;

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
    
    // Fix bug cannot touch on the last row in case there are many photos or data
    if (SC_IS_IPHONE5) {
        float delta = 0;
        if (![SCHelper isIOS7]) {
            delta = 12;
        }
        self.itemView.frame = CGRectMake(self.itemView.frame.origin.x,
                                         self.itemView.frame.origin.y,
                                         self.itemView.frame.size.width,
                                         self.itemView.frame.size.height - 60 - delta);
    }
    
    if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeSingle) {
        self.nextBtn.hidden = YES;
    } else if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeSingle) {
        self.nextBtn.hidden = NO;
    }
    
    if (library == nil) {
        library = [[ALAssetsLibrary alloc] init];
    }
    
    self.indexDownloaded = 0;
    
    self.selectedArray = [[NSMutableArray alloc] init];
    self.orderSelectedArray = [[NSMutableArray alloc] init];
    
    //self.data = [[NSMutableArray alloc]init];
    
    [self populateSelectedArray];
    
    //init grid view
    self.gridView = [[SCItemGridView alloc] initWith:self.itemView.bounds
                                             andType:SCGridViewTypeVertical
                                   numberItemPerPage:self.data.count];
    [self.gridView setDelegate:self];
    [self.itemView addSubview:self.gridView];
    [self.gridView setData:self.data];
    //[self finishedLoadAllPhotos];
    
    //[self.gridView setData:self.data];
    //notice that grid view is using static data
    [self.gridView setIsUsingDynamicData:NO];
    [self updateNumberPhotoSelected];
    
    if (self.gridView.gridView.contentSize.height > self.gridView.frame.size.height) {
        [self.gridView.gridView setContentOffset:CGPointMake(self.gridView.gridView.contentOffset.x,
                                                             self.gridView.gridView.contentSize.height - self.gridView.frame.size.height)
                                        animated:NO];
    }
    
    [self.gridView.gridView reloadData];
}

- (void)reloadWithData:(NSMutableArray*)array {
    self.data = array;
    [self finishedLoadAllPhotos];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SCItemGridViewCell *)SCitemGridView:(SCItemGridView *)itemGridView cellForItemAtIndex:(int)index
{
    SCPhotoItemView *cell = (SCPhotoItemView*)[itemGridView.gridView dequeueReusableCellWithIdentifier:@"SCItemGridViewCell"];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SCPhotoItemView" owner:self options:nil] objectAtIndex:0];
    }
    
    SCSlideComposition *slideComposition = (SCSlideComposition*)[self.data objectAtIndex:index];
    cell.photoImgView.image = slideComposition.thumbnailImage;
    
    // display checkmark icon
    NSNumber *selected = [self.selectedArray objectAtIndex:index];
    if ([selected boolValue]) {
        cell.checkMarkView.hidden = NO;
        cell.checkMarkImgView.hidden = NO;
    } else {
        cell.checkMarkView.hidden = YES;
        cell.checkMarkImgView.hidden = YES;
    }

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
    
    if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeMultiple) {
        
        // display checkmark icon
        BOOL selected = [[self.selectedArray objectAtIndex:index] boolValue];
        [self.selectedArray replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:!selected]];
        
        [self putOrderSelectedArray:index selected:!selected];
        
        if (selected) {
            ((SCPhotoItemView*)cell).checkMarkView.hidden = YES;
            ((SCPhotoItemView*)cell).checkMarkImgView.hidden = YES;
        } else {
            ((SCPhotoItemView*)cell).checkMarkView.hidden = NO;
            ((SCPhotoItemView*)cell).checkMarkImgView.hidden = NO;

        }
        
        [self updateNumberPhotoSelected];
        
    } else if ([SCPhotoSettingManager getInstance].photoChooseType == SCEnumPhotoChooseTypeSingle) {
        
        SCSlideComposition *slideComposition = (SCSlideComposition*)[self.data objectAtIndex:index];
        
        [library assetForURL:slideComposition.assetURL
                 resultBlock:^(ALAsset *asset)
        {
            //resize image first
            UIImage *temp = [[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage] resizedImageWithMinimumSize:SC_CROP_PHOTO_SIZE];
            //second : crop the image from th top
            //slideComposition.image = [SCImageUtil cropImageWith:temp rect:CGRectMake(0, 0, SC_CROP_PHOTO_SIZE.width, SC_CROP_PHOTO_SIZE.height)];
            slideComposition.image = temp;
            slideComposition.originalImage = temp;
            //slideComposition.isCropped = YES;
            temp = nil;
            asset = nil;

            [self.delegate dismissPhotoPickerWithSlideComposition:slideComposition];
            
//            [self dismissPresentScreenWithAnimated:YES completion:^{
//                [self.delegate dismissPhotoPickerWithSlideComposition:slideComposition];
//            }];
         
        }
        failureBlock:^(NSError *error){
                
        } ];
    }
}

#pragma mark - ibactions
- (IBAction)onBackBtn:(id)sender
{
    // before not use it
    //[self dismissViewControllerAnimated:YES completion:nil];
    // [self clearAll];
    
    // before use it
    //[self.delegate dismissPhotoPicker];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)onNextBtn:(id)sender {
    if ([self.delegate respondsToSelector:@selector(dismissPhotoPickerWithData:)])
    {
        /*
        NSMutableArray *parseArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.selectedArray.count; i++) {
            BOOL selected = [[self.selectedArray objectAtIndex:i] boolValue];
            if (selected) {
                [parseArray addObject:(SCSlideComposition*)[self.data objectAtIndex:i]];
            }
        }
         */
        
        NSMutableArray *parseArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.orderSelectedArray.count; i++) {
            NSNumber *num = (NSNumber*)[self.orderSelectedArray objectAtIndex:i];
            SCSlideComposition *slideComposition = [self.data objectAtIndex:[num intValue]];
            slideComposition.needToUpdate = YES;
            [parseArray addObject:slideComposition];
        }
        
        [self.delegate dismissPhotoPickerWithData:parseArray];

    }
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self clearAll];

}

#pragma mark - get Photos from Photo Camera Roll
-(void)getAllPictures
{
    //[SVProgressHUD showWithStatus:NSLocalizedString(@"loading", nil) maskType:SVProgressHUDMaskTypeClear];
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(loadAllPhotos)
                                                                              object:nil];
    [queue addOperation:operation];
}

- (void)loadAllPhotos {

    imageArray = [[NSMutableArray alloc] init];
    mutableArray = [[NSMutableArray alloc]init];
    
    library = [[ALAssetsLibrary alloc] init];
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if (result) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                
                NSURL *url= (NSURL*) [[result defaultRepresentation]url];
                UIImage *thumbnailImage = [UIImage imageWithCGImage:[result thumbnail]];
                UIImage *resizeThumbnail = [SCImageUtil imageWithImage:thumbnailImage scaledToSize:SC_THUMBNAIL_IMAGE_SIZE];
                SCSlideComposition *slideComposition = [[SCSlideComposition alloc] initWithThumbnailImage:resizeThumbnail assetURL:url];
                
                [self.data addObject:slideComposition];
                
                thumbnailImage = nil;
            }
        } else {
            [self performSelectorOnMainThread:@selector(finishedLoadAllPhotos) withObject:nil waitUntilDone:YES];
        }
    };
    
    ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    [self.assetGroup setAssetsFilter:onlyPhotosFilter];
    [self.assetGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    
}

- (void)finishedLoadAllPhotos {
    
//    self.gridView.alpha = 0;
    
    [self populateSelectedArray];
    [self.gridView setData:self.data];
    
    //[self.gridView resetWithData:self.data];
    //[SVProgressHUD dismiss];
    
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         self.gridView.alpha = 1;
//                     }
//                     completion:^(BOOL finished){
//                         
//                     }];
    
    // goto bottom
    if (self.gridView.gridView.contentSize.height > self.gridView.frame.size.height) {
        [self.gridView.gridView setContentOffset:CGPointMake(self.gridView.gridView.contentOffset.x,
                                                             self.gridView.gridView.contentSize.height - self.gridView.frame.size.height)
                                        animated:NO];
    }
    
    [self.gridView.gridView reloadData];
}


#pragma mark - Selected array
- (void) populateSelectedArray {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[self.data count]];
    for (int i=0; i < [self.data count]; i++) {
        [array addObject:[NSNumber numberWithBool:NO]];
    }
    [self.selectedArray removeAllObjects];
    self.selectedArray = array;
}

- (void)updateNumberPhotoSelected {
    
    int num = 0;
    for (int i = 0; i < self.selectedArray.count; i++) {
        BOOL selected = [[self.selectedArray objectAtIndex:i] boolValue];
        if (selected) {
            num++;
        }
    }
    
    self.numOfPhotoSelectedLb.text = [NSString stringWithFormat:@"%@ %@ Selected",
                                      (num==0)?@"No":[NSString stringWithFormat:@"%d", num],
                                      ((num==1)||(num==0))?@"Photo":@"Photos"];
}

- (void)putOrderSelectedArray:(int)index selected:(BOOL)selected {
    if (selected) {
        // add
        [self.orderSelectedArray addObject:[NSNumber numberWithInt:index]];
    } else {
        // remove
        for (int i = 0; i < self.orderSelectedArray.count; i++) {
            NSNumber *num = (NSNumber*)[self.orderSelectedArray objectAtIndex:i];
            if ([num intValue] == index) {
                [self.orderSelectedArray removeObjectAtIndex:i];
            }
        }
    }
}

#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
    self.delegate = nil;
    if(self.data.count > 0)
    {
        [self.data removeAllObjects];
    }
    self.data = nil;
    
    if(self.selectedArray.count > 0)
    {
        [self.selectedArray removeAllObjects];
    }
    self.selectedArray = nil;
    
    if (self.orderSelectedArray.count > 0) {
        [self.orderSelectedArray removeAllObjects];
    }
    self.orderSelectedArray = nil;
}


@end
