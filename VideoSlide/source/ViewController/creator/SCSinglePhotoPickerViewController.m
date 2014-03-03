//
//  SCSinglePhotoPickerViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSinglePhotoPickerViewController.h"
#import <ImageIO/ImageIO.h>

@interface SCSinglePhotoPickerViewController () <SCItemGridViewProtocol, SCPhotoCropViewControllerDeletate> {
    ALAssetsLibrary *library;
    NSMutableArray *imageArray;
    NSMutableArray *mutableArray;
    
}

@property (nonatomic, strong) IBOutlet UIView   *itemView;
@property (nonatomic, strong) SCItemGridView    *gridView;
@property (nonatomic, strong) NSMutableArray    *data;
@property (nonatomic, strong) NSMutableArray    *selectedArray;
@property (nonatomic, strong) IBOutlet UILabel  *numOfPhotoSelectedLb;
@property (nonatomic, strong) ALAssetsGroup     *assetGroup;
@property (nonatomic, assign) int               indexDownloaded;
- (IBAction)onBackBtn:(id)sender;
- (IBAction)onNextBtn:(id)sender;

@end

static int count = 0;

@implementation SCSinglePhotoPickerViewController
@synthesize delegate;
@synthesize assetGroup;

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
    
    self.indexDownloaded = 0;
    
    self.selectedArray = [[NSMutableArray alloc] init];
    self.data = [[NSMutableArray alloc]init];

    //init grid view
    self.gridView = [[SCItemGridView alloc] initWith:self.itemView.bounds
                                             andType:SCGridViewTypeVertical
                                   numberItemPerPage:self.data.count];
    [self.gridView setDelegate:self];
    [self.gridView setData:self.data];
    
    //notice that grid view is using static data
    [self.gridView setIsUsingDynamicData:NO];
    
    //add to View
    [self.itemView addSubview:self.gridView];
    
    [self getAllPictures];

    [self updateNumberPhotoSelected];
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
    cell.checkMarkView.hidden = YES;
    cell.checkMarkImgView.hidden = YES;
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

        [self dismissPresentScreenWithAnimated:YES completion:^{
            [self.delegate dismissPhotoPickerWithSlideComposition:slideComposition];
        }];
        
    }
    failureBlock:^(NSError *error){
                
            } ];
}

#pragma mark - get Photos from Photo Camera Roll
-(void)getAllPictures
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"loading", nil) maskType:SVProgressHUDMaskTypeClear];
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(loadAllPhotos)
                                                                              object:nil];
    [queue addOperation:operation];
}

- (void)loadAllPhotos {
    imageArray=[[NSMutableArray alloc] init];
    mutableArray =[[NSMutableArray alloc]init];
    
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    library = [[ALAssetsLibrary alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                
                [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                
                NSURL *url= (NSURL*) [[result defaultRepresentation]url];
                UIImage *thumbnailImage = [UIImage imageWithCGImage:[result thumbnail]];
                
                SCSlideComposition *slideComposition = [[SCSlideComposition alloc] initWithThumbnailImage:thumbnailImage assetURL:url];
                
                [self.data addObject:slideComposition];
            }
        } else {
            [self performSelectorOnMainThread:@selector(finishedLoadAllPhotos) withObject:nil waitUntilDone:YES];
        }
    };
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
            count=[group numberOfAssets];
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
}

- (void)finishedLoadAllPhotos {
    [self populateSelectedArray];
    [self.gridView resetWithData:self.data];
    [SVProgressHUD dismiss];
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

- (IBAction)onCancelBtn:(id)sender
{ 
    [self dismissPresentScreen];
}

- (UIImage*)thumbnailImage:(UIImage*)image withSize:(CGSize)size {
    
    CGSize _reduceSize;
    if (image.size.width > image.size.height) {
        _reduceSize = CGSizeMake(image.size.width/(image.size.height/640), 640);
    } else if (image.size.width < image.size.height) {
        _reduceSize = CGSizeMake(640, image.size.height/(image.size.width/640));
    } else if (image.size.width == image.size.height) {
        _reduceSize = CGSizeMake(640, 640);
    }
    
    UIImage *reduceImage = [SCImageUtil newImageWithImage:image scaledToSize:_reduceSize];
    UIImage *thumbnailImage = [SCImageUtil thumbnailWithImage:reduceImage withSize:size] ;
    
    return thumbnailImage;
}

#pragma mark - clearl all

- (void)clearAll
{
    [super clearAll];
    
    //self.data = nil;
    self.delegate = nil;
}

@end
