//
//  SCPhotoCropViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCPhotoCropViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface SCPhotoCropViewController () {
    float   lastScale;
    CGRect  lastFrame;
    ALAssetsLibrary *library;
}

@property (nonatomic, strong) IBOutlet UIView       *topOverlayView;
@property (nonatomic, strong) IBOutlet UIView       *bottomOverlayView;
@property (nonatomic, strong) IBOutlet UIView       *gridContainerView;
@property (nonatomic, strong) IBOutlet UIImageView  *originalImgView;
@property (nonatomic, strong) IBOutlet UIView       *navigationView;

@property (nonatomic, strong) IBOutlet UILabel      *numberIndexLb;

@property (nonatomic, strong) IBOutlet UIButton     *nextPhotoBtn;
@property (nonatomic, strong) IBOutlet UIButton     *previousPhotoBtn;

@property (nonatomic, strong) IBOutlet UIButton     *closeCropArrayBtn;
@property (nonatomic, strong) IBOutlet UIButton     *closeCropOnePhotoBtn;

@property (nonatomic, weak) SCSlideComposition      *slideComposition;

@property (nonatomic, assign) SCCropType            currentCropType;

- (IBAction)onCropBtn:(id)sender;
- (IBAction)onCancelBtn:(id)sender;
- (IBAction)onRecropBtn:(id)sender;
- (IBAction)onNextPhotosBtn:(id)sender;
- (IBAction)onPreviousPhotosBtn:(id)sender;
- (IBAction)onCancelNewBtn:(id)sender;
@end

@implementation SCPhotoCropViewController
@synthesize currentOriginalImage;
@synthesize data;
@synthesize currentPhotoIndex;
@synthesize delegate;
@synthesize instantRectCropped = _instantRectCropped;

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

    self.view.clipsToBounds = YES;
    
    // resize UI for iPhone 5
    [self autoResizeiPhone5];
    
    if ([[self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_DATA] isKindOfClass:[SCSlideComposition class]]) {
        
        self.currentCropType = SCCropTypeSingle;
        
        //[self resetUIOnePhotoToCrop];
        [self resetUIForInstantCrop];
        
        self.slideComposition = [self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_DATA];
        self.data = [[NSMutableArray alloc] initWithObjects:self.slideComposition, nil];
        self.currentPhotoIndex = 0;

        library = [[ALAssetsLibrary alloc] init];
    } else {
        
        self.currentCropType = SCCropTypeMultiple;
        
        //[self resetUIArrayToCrop];
        [self resetUIForInstantCrop];
        
        self.data = [self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_ARRAY];
        self.currentPhotoIndex = [self.lastData integerForKey:SC_TRANSIT_KEY_SLIDE_DATA_INDEX];
    
        // UI
        library = [[ALAssetsLibrary alloc] init];
        [self displayNumberIndexLb];
    }
    
    [self displayOriginalImageAtIndex:self.currentPhotoIndex];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.closeCropOnePhotoBtn setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)displayNumberIndexLb {
    self.numberIndexLb.text = [NSString stringWithFormat:@"%d of %d", self.currentPhotoIndex + 1, self.data.count];
    
    // display correct button state for next/previous
    if ((self.currentPhotoIndex == 0) && (self.data.count > 1)) {
        [self.nextPhotoBtn setImage:[UIImage imageNamed:@"btn_photoview_next_item.png"] forState:UIControlStateNormal];
        [self.previousPhotoBtn setImage:[UIImage imageNamed:@"btn_photoview_previous_item_disable.png"] forState:UIControlStateNormal];
    } else if (((self.currentPhotoIndex + 1) == self.data.count)  && (self.data.count > 1)) {
        [self.nextPhotoBtn setImage:[UIImage imageNamed:@"btn_photoview_next_item_disable.png"] forState:UIControlStateNormal];
        [self.previousPhotoBtn setImage:[UIImage imageNamed:@"btn_photoview_previous_item.png"] forState:UIControlStateNormal];
    } else if (self.data.count == 1) {
        [self.nextPhotoBtn setImage:[UIImage imageNamed:@"btn_photoview_next_item_disable.png"] forState:UIControlStateNormal];
        [self.previousPhotoBtn setImage:[UIImage imageNamed:@"btn_photoview_previous_item_disable.png"] forState:UIControlStateNormal];
    } else {
        [self.nextPhotoBtn setImage:[UIImage imageNamed:@"btn_photoview_next_item.png"] forState:UIControlStateNormal];
        [self.previousPhotoBtn setImage:[UIImage imageNamed:@"btn_photoview_previous_item.png"] forState:UIControlStateNormal];
    }
}

- (void)autoResizeiPhone5 {
    if (SC_IS_IPHONE5) {
        self.topOverlayView.frame = CGRectMake(0, 0, 320, 92);
        self.gridContainerView.frame = CGRectMake(0, 92, 320, 320);
        self.bottomOverlayView.frame = CGRectMake(0, 412, 320, 92);
    }
}

- (void)resetUIForInstantCrop {
    self.numberIndexLb.hidden = YES;
    self.nextPhotoBtn.hidden = YES;
    self.previousPhotoBtn.hidden = YES;
    self.closeCropArrayBtn.hidden = YES;
    
    self.closeCropOnePhotoBtn.hidden = YES;

}

- (void)resetUIArrayToCrop {
    self.numberIndexLb.hidden = NO;
    self.nextPhotoBtn.hidden = NO;
    self.previousPhotoBtn.hidden = NO;
    self.closeCropArrayBtn.hidden = NO;
    
    self.closeCropOnePhotoBtn.hidden = YES;
}

- (void)resetUIOnePhotoToCrop {
    self.numberIndexLb.hidden = YES;
    self.nextPhotoBtn.hidden = YES;
    self.previousPhotoBtn.hidden = YES;
    self.closeCropArrayBtn.hidden = YES;
    
    self.closeCropOnePhotoBtn.hidden = NO;
}

- (void)displayOriginalImageAtIndex:(int)index {
    
    SCSlideComposition *slide = (SCSlideComposition*)[self.data objectAtIndex:index];
    void (^resetOriginalImage)(void) = ^
    {
        if ((slide.rectCropped.size.width > 0) && (slide.rectCropped.size.height > 0)) {
            self.originalImgView.frame = slide.rectCropped;
            self.originalImgView.contentMode = UIViewContentModeScaleAspectFit;
            self.originalImgView.image = self.currentOriginalImage;
            //lastFrame = self.gridContainerView.frame;
            
            
            if (self.currentOriginalImage.size.width > self.currentOriginalImage.size.height) {
                
                float newWidth = self.currentOriginalImage.size.width/(self.currentOriginalImage.size.height/320);
                
                lastFrame = CGRectMake(self.gridContainerView.frame.origin.x - ((newWidth - self.gridContainerView.frame.size.width)/2),
                                       self.gridContainerView.frame.origin.y,
                                       newWidth,
                                       320);
            } else if (self.currentOriginalImage.size.width < self.currentOriginalImage.size.height) {
                
                float newHeight = self.currentOriginalImage.size.height/(self.currentOriginalImage.size.width/320);
                
                lastFrame = CGRectMake(self.gridContainerView.frame.origin.x,
                                       self.gridContainerView.frame.origin.y - ((newHeight - self.gridContainerView.frame.size.height)/2),
                                       320,
                                       newHeight);
                
            } else if (self.currentOriginalImage.size.width == self.currentOriginalImage.size.height) {
                lastFrame = CGRectMake(self.gridContainerView.frame.origin.x,
                                       self.gridContainerView.frame.origin.y,
                                       320,
                                       320);
            }
            
        } else {
            
            lastScale = 1.0;
            
            if (self.currentOriginalImage.size.width > self.currentOriginalImage.size.height) {
                
                float newWidth = self.currentOriginalImage.size.width/(self.currentOriginalImage.size.height/320);
                
                self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x - ((newWidth - self.gridContainerView.frame.size.width)/2),
                                                        self.gridContainerView.frame.origin.y,
                                                        newWidth,
                                                        320);
            } else if (self.currentOriginalImage.size.width < self.currentOriginalImage.size.height) {
                
                float newHeight = self.currentOriginalImage.size.height/(self.currentOriginalImage.size.width/320);
                
                self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x,
                                                        self.gridContainerView.frame.origin.y - ((newHeight - self.gridContainerView.frame.size.height)/2),
                                                        320,
                                                        newHeight);
                
            } else if (self.currentOriginalImage.size.width == self.currentOriginalImage.size.height) {
                self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x,
                                                        self.gridContainerView.frame.origin.y,
                                                        320,
                                                        320);
            }
            
            self.originalImgView.contentMode = UIViewContentModeScaleAspectFit;
            self.originalImgView.image = self.currentOriginalImage;
            
            lastFrame = self.originalImgView.frame;
        }
    };
    
    if (slide.assetURL) {
        [library assetForURL:slide.assetURL
                 resultBlock:^(ALAsset *asset) {
                     
                     UIImage *fullImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:asset.defaultRepresentation.scale orientation:0];
                     
                     self.currentOriginalImage = fullImage;
                     resetOriginalImage();
                     
                 }
                failureBlock:^(NSError *error){ NSLog(@"operation was not successfull!"); } ];
    } else {
        self.currentOriginalImage = slide.originalImage;
        resetOriginalImage();
    }
    
    /*
    if (slide.image) {
        self.currentOriginalImage = slide.image;
        resetOriginalImage();
    } else {
        [library assetForURL:slide.assetURL
                 resultBlock:^(ALAsset *asset) {
                     
                        UIImage *fullImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:asset.defaultRepresentation.scale orientation:0];

                        self.currentOriginalImage = fullImage;
                        resetOriginalImage();

                }
                failureBlock:^(NSError *error){ NSLog(@"operation was not successfull!"); } ];
            
    }
     */
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {

    
    CGPoint translation = [recognizer translationInView:self.view];
    
    if (self.originalImgView.frame.size.height == 320) {

        if (translation.x >= 0) {
            self.originalImgView.center = CGPointMake(MIN(self.originalImgView.center.x + translation.x, self.originalImgView.frame.size.width/2),
                                                      self.originalImgView.center.y);
        } else {
            self.originalImgView.center = CGPointMake(MAX(self.originalImgView.center.x + translation.x, 320 - self.originalImgView.frame.size.width/2),
                                                      self.originalImgView.center.y);
        }

    } else if (self.originalImgView.frame.size.width == 320) {
        
        if (translation.y >= 0) {
            self.originalImgView.center = CGPointMake(self.originalImgView.center.x,
                                                      MIN(
                                                          self.originalImgView.center.y + translation.y,
                                                          self.originalImgView.frame.size.height/2 + self.gridContainerView.frame.origin.y));
        } else {
            self.originalImgView.center = CGPointMake(self.originalImgView.center.x,
                                                      MAX(
                                                          self.originalImgView.center.y + translation.y,
                                                          (self.gridContainerView.frame.origin.y + 320) - self.originalImgView.frame.size.height/2)
                                                      );
        }
    }
    
    
    else if ((self.originalImgView.frame.size.width > 320) || (self.originalImgView.frame.size.height > 320)) {
        
        if ((translation.x >= 0) && (translation.y >= 0)) {
            self.originalImgView.frame = CGRectMake(MIN(
                                                        self.originalImgView.frame.origin.x + translation.x,
                                                        self.gridContainerView.frame.origin.x
                                                        ),
                                                    MIN(
                                                        self.originalImgView.frame.origin.y + translation.y,
                                                        self.gridContainerView.frame.origin.y
                                                        ),
                                                    self.originalImgView.frame.size.width,
                                                    self.originalImgView.frame.size.height);
        } else if ((translation.x <= 0) && (translation.y >= 0)) {
            self.originalImgView.frame = CGRectMake(MAX(
                                                        self.originalImgView.frame.origin.x + translation.x,
                                                        320 - self.originalImgView.frame.size.width
                                                        ),
                                                    MIN(
                                                        self.originalImgView.frame.origin.y + translation.y,
                                                        self.gridContainerView.frame.origin.y
                                                        ),
                                                    self.originalImgView.frame.size.width,
                                                    self.originalImgView.frame.size.height);
        } else if ((translation.x >= 0) && (translation.y <= 0)) {
            self.originalImgView.frame = CGRectMake(MIN(
                                                        self.originalImgView.frame.origin.x + translation.x,
                                                        self.gridContainerView.frame.origin.x
                                                        ),
                                                    MAX(
                                                        self.originalImgView.frame.origin.y + translation.y,
                                                        (self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y) - self.originalImgView.frame.size.height
                                                        ),
                                                    self.originalImgView.frame.size.width,
                                                    self.originalImgView.frame.size.height);
        } else if ((translation.x <= 0) && (translation.y <= 0)) {
            self.originalImgView.frame = CGRectMake(MAX(
                                                        self.originalImgView.frame.origin.x + translation.x,
                                                        320 - self.originalImgView.frame.size.width
                                                        ),
                                                    MAX(
                                                        self.originalImgView.frame.origin.y + translation.y,
                                                        (self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y) - self.originalImgView.frame.size.height
                                                        ),
                                                    self.originalImgView.frame.size.width,
                                                    self.originalImgView.frame.size.height);
        }
        
        
        
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    self.originalImgView.transform = CGAffineTransformScale(self.originalImgView.transform, recognizer.scale, recognizer.scale);
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        
        lastScale = recognizer.scale;
        
        // all image smaller than grid
        if (self.originalImgView.frame.size.width < 320 || self.originalImgView.frame.size.height < 320) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.originalImgView.frame = lastFrame;
                             }
                             completion:^(BOOL finished){
                                 
                             }];
        }
        
        // all image larger than grid, but wrong position
        else if (self.originalImgView.frame.size.width > 320 || self.originalImgView.frame.size.height > 320) {
            
            // wrong right edge
            if (
                ((320 - (self.originalImgView.frame.size.width + self.originalImgView.frame.origin.x)) > 0)
                && (self.originalImgView.frame.origin.y < self.gridContainerView.frame.origin.y)
                && (((self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y)
                     - (self.originalImgView.frame.size.height + self.originalImgView.frame.origin.y)) < 0)
                ){
                
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.originalImgView.frame = CGRectMake(self.originalImgView.frame.origin.x
                                                                             +(320 - (self.originalImgView.frame.size.width + self.originalImgView.frame.origin.x)),
                                                                             self.originalImgView.frame.origin.y,
                                                                             self.originalImgView.frame.size.width,
                                                                             self.originalImgView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
            
            // wrong left edge
            else if ((self.originalImgView.frame.origin.x > 0)
                     && (self.originalImgView.frame.origin.y < self.gridContainerView.frame.origin.y)
                     && (((self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y)
                          - (self.originalImgView.frame.size.height + self.originalImgView.frame.origin.y)) < 0)
                     ) {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.originalImgView.frame = CGRectMake(0,
                                                                             self.originalImgView.frame.origin.y,
                                                                             self.originalImgView.frame.size.width,
                                                                             self.originalImgView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
            
            // wrong top edge
            else if (
                (self.originalImgView.frame.origin.y > self.gridContainerView.frame.origin.y)
                && (self.originalImgView.frame.origin.x < 0)
                && ((320 - (self.originalImgView.frame.size.width + self.originalImgView.frame.origin.x)) < 0)
                )
            {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.originalImgView.frame = CGRectMake(self.originalImgView.frame.origin.x,
                                                                             self.gridContainerView.frame.origin.y,
                                                                             self.originalImgView.frame.size.width,
                                                                             self.originalImgView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
            // wrong bottom edge
            else if (
                     
                     ((self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y)
                     - (self.originalImgView.frame.size.height + self.originalImgView.frame.origin.y)) > 0
                     && (self.originalImgView.frame.origin.x < 0)
                     && ((320 - (self.originalImgView.frame.size.width + self.originalImgView.frame.origin.x)) < 0)
                     )
            {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.originalImgView.frame = CGRectMake(self.originalImgView.frame.origin.x,
                                                                             self.originalImgView.frame.origin.y
                                                                             + ((self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y)
                                                                                - (self.originalImgView.frame.size.height + self.originalImgView.frame.origin.y)),
                                                                             self.originalImgView.frame.size.width,
                                                                             self.originalImgView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
            
            // wrong top-left corner
            else if ((self.originalImgView.frame.origin.x > 0) && (self.originalImgView.frame.origin.y > self.gridContainerView.frame.origin.y)){
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.originalImgView.frame = CGRectMake(0,
                                                                             self.gridContainerView.frame.origin.y,
                                                                             self.originalImgView.frame.size.width,
                                                                             self.originalImgView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
            
            // wrong top-right corner
            else if (((320 - (self.originalImgView.frame.size.width + self.originalImgView.frame.origin.x)) > 0)
                       &&
                       (self.originalImgView.frame.origin.y > self.gridContainerView.frame.origin.y)){
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.originalImgView.frame = CGRectMake(self.originalImgView.frame.origin.x
                                                                             +(320 - (self.originalImgView.frame.size.width + self.originalImgView.frame.origin.x)),
                                                                             self.gridContainerView.frame.origin.y,
                                                                             self.originalImgView.frame.size.width,
                                                                             self.originalImgView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
            
            // wrong bottom-left corner
            else if ((self.originalImgView.frame.origin.x > 0)
                     && (self.originalImgView.frame.origin.y < self.gridContainerView.frame.origin.y)
                     && (((self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y)
                      - (self.originalImgView.frame.size.height + self.originalImgView.frame.origin.y)) > 0)
                     ) {
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.originalImgView.frame = CGRectMake(0,
                                                                             self.originalImgView.frame.origin.y
                                                                             + ((self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y)
                                                                                - (self.originalImgView.frame.size.height + self.originalImgView.frame.origin.y)),
                                                                             self.originalImgView.frame.size.width,
                                                                             self.originalImgView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
            
            // wrong bottom-right corner
            else if (
                     ((320 - (self.originalImgView.frame.size.width + self.originalImgView.frame.origin.x)) > 0)
                     && (self.originalImgView.frame.origin.y < self.gridContainerView.frame.origin.y)
                     && (((self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y)
                          - (self.originalImgView.frame.size.height + self.originalImgView.frame.origin.y)) > 0)
                     )
            {
                
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     self.originalImgView.frame = CGRectMake(self.originalImgView.frame.origin.x
                                                                             +(320 - (self.originalImgView.frame.size.width + self.originalImgView.frame.origin.x)),
                                                                             self.originalImgView.frame.origin.y
                                                                             + ((self.gridContainerView.frame.size.height + self.gridContainerView.frame.origin.y)
                                                                                - (self.originalImgView.frame.size.height + self.originalImgView.frame.origin.y)),
                                                                             self.originalImgView.frame.size.width,
                                                                             self.originalImgView.frame.size.height);
                                 }
                                 completion:^(BOOL finished){
                                 }];
            }
        }
    }
    
    recognizer.scale = 1;
}

#pragma mark - IBActions
- (IBAction)onCropBtn:(id)sender
{
    [self.closeCropOnePhotoBtn setHidden:NO];
    UIImage *cropedImage = [self thumbnailWithImage:self.originalImgView.image];
    
    SCSlideComposition *slide = (SCSlideComposition*)[self.data objectAtIndex:self.currentPhotoIndex];
    
    slide.isCropped = YES;
    slide.needToUpdate  = YES;
    slide.image = cropedImage;
    slide.thumbnailImage     =  [SCImageUtil imageWithImage:slide.image scaledToSize:SC_THUMBNAIL_IMAGE_SIZE];
    slide.rectCropped = self.instantRectCropped;

    
    slide.needToRefreshThumbnail = YES;
    
    if (self.currentCropType == SCCropTypeSingle) {
        
        if([self.delegate respondsToSelector:@selector(closeCropViewWithOnePhoto:)])
            [self.delegate closeCropViewWithOnePhoto:(SCSlideComposition*)[self.data objectAtIndex:0]];
        [self dismissPresentScreen];
        
    } else if (self.currentCropType == SCCropTypeMultiple) {
        
        if([self.delegate respondsToSelector:@selector(closeCropViewWithData:)])
            [self.delegate closeCropViewWithData:self.data];
        [self dismissPresentScreen];
    }

}

- (IBAction)onCancelNewBtn:(id)sender {
    [self dismissPresentScreen];
}

- (IBAction)onCancelBtn:(id)sender
{
    if([self.delegate respondsToSelector:@selector(closeCropViewWithData:)])
        [self.delegate closeCropViewWithData:self.data];
    [self dismissPresentScreen];
}

- (IBAction)onCloseCropOnePhoto:(id)sender {
    if([self.delegate respondsToSelector:@selector(closeCropViewWithOnePhoto:)])
        [self.delegate closeCropViewWithOnePhoto:(SCSlideComposition*)[self.data objectAtIndex:0]];
    [self dismissPresentScreen];
}

- (IBAction)onRecropBtn:(id)sender {
    
    SCSlideComposition *slide = (SCSlideComposition*)[self.data objectAtIndex:self.currentPhotoIndex];
    if ((slide.assetURL == nil) || [[slide.assetURL absoluteString] isEqualToString:@""]) {
        self.currentOriginalImage = slide.originalImage;
        
        lastScale = 1.0;
        
        if (self.currentOriginalImage.size.width > self.currentOriginalImage.size.height) {
            
            float newWidth = self.currentOriginalImage.size.width/(self.currentOriginalImage.size.height/320);
            
            self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x - ((newWidth - self.gridContainerView.frame.size.width)/2),
                                                    self.gridContainerView.frame.origin.y,
                                                    newWidth,
                                                    320);
        } else if (self.currentOriginalImage.size.width < self.currentOriginalImage.size.height) {
            
            float newHeight = self.currentOriginalImage.size.height/(self.currentOriginalImage.size.width/320);
            
            self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x,
                                                    self.gridContainerView.frame.origin.y - ((newHeight - self.gridContainerView.frame.size.height)/2),
                                                    320,
                                                    newHeight);
            
        } else if (self.currentOriginalImage.size.width == self.currentOriginalImage.size.height) {
            self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x,
                                                    self.gridContainerView.frame.origin.y,
                                                    320,
                                                    320);
        }
        
        self.originalImgView.contentMode = UIViewContentModeScaleAspectFit;
        self.originalImgView.image = self.currentOriginalImage;
        
        lastFrame = self.originalImgView.frame;
    } else {
        
        if(slide.originalImage)
        {
            self.currentOriginalImage = slide.originalImage;
            
            lastScale = 1.0;
            
            if (self.currentOriginalImage.size.width > self.currentOriginalImage.size.height) {
                
                float newWidth = self.currentOriginalImage.size.width/(self.currentOriginalImage.size.height/320);
                
                self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x - ((newWidth - self.gridContainerView.frame.size.width)/2),
                                                        self.gridContainerView.frame.origin.y,
                                                        newWidth,
                                                        320);
            } else if (self.currentOriginalImage.size.width < self.currentOriginalImage.size.height) {
                
                float newHeight = self.currentOriginalImage.size.height/(self.currentOriginalImage.size.width/320);
                
                self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x,
                                                        self.gridContainerView.frame.origin.y - ((newHeight - self.gridContainerView.frame.size.height)/2),
                                                        320,
                                                        newHeight);
                
            } else if (self.currentOriginalImage.size.width == self.currentOriginalImage.size.height) {
                self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x,
                                                        self.gridContainerView.frame.origin.y,
                                                        320,
                                                        320);
            }
            
            self.originalImgView.contentMode = UIViewContentModeScaleAspectFit;
            self.originalImgView.image = self.currentOriginalImage;
            
            lastFrame = self.originalImgView.frame;

        }
        else
        {
            [library assetForURL:slide.assetURL
                 resultBlock:^(ALAsset *asset) {
                     
                     UIImage *fullImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:asset.defaultRepresentation.scale orientation:0];
                     
                     self.currentOriginalImage = fullImage;
                     
                     lastScale = 1.0;
                     
                     if (self.currentOriginalImage.size.width > self.currentOriginalImage.size.height) {
                         
                         float newWidth = self.currentOriginalImage.size.width/(self.currentOriginalImage.size.height/320);
                         
                         self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x - ((newWidth - self.gridContainerView.frame.size.width)/2),
                                                                 self.gridContainerView.frame.origin.y,
                                                                 newWidth,
                                                                 320);
                     } else if (self.currentOriginalImage.size.width < self.currentOriginalImage.size.height) {
                         
                         float newHeight = self.currentOriginalImage.size.height/(self.currentOriginalImage.size.width/320);
                         
                         self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x,
                                                                 self.gridContainerView.frame.origin.y - ((newHeight - self.gridContainerView.frame.size.height)/2),
                                                                 320,
                                                                 newHeight);
                         
                     } else if (self.currentOriginalImage.size.width == self.currentOriginalImage.size.height) {
                         self.originalImgView.frame = CGRectMake(self.gridContainerView.frame.origin.x,
                                                                 self.gridContainerView.frame.origin.y,
                                                                 320,
                                                                 320);
                     }
                     
                     self.originalImgView.contentMode = UIViewContentModeScaleAspectFit;
                     self.originalImgView.image = self.currentOriginalImage;
                     
                     lastFrame = self.originalImgView.frame;
                     
                 }
                failureBlock:^(NSError *error){ NSLog(@"operation was not successfull!"); } ];
        }
    }
}

- (IBAction)onNextPhotosBtn:(id)sender {
    if (self.currentPhotoIndex == (self.data.count - 1)) {
        return;
    }
    self.currentPhotoIndex++;
    [self displayOriginalImageAtIndex:self.currentPhotoIndex];
    [self displayNumberIndexLb];
}

- (IBAction)onPreviousPhotosBtn:(id)sender {
    if (self.currentPhotoIndex == 0) {
        return;
    }
    self.currentPhotoIndex--;
    [self displayOriginalImageAtIndex:self.currentPhotoIndex];
    [self displayNumberIndexLb];
}

- (UIImage *)thumbnailWithImage:(UIImage *)image
{
    self.instantRectCropped = self.originalImgView.frame;
    
    CGSize scale = CGSizeMake(self.currentOriginalImage.size.width / self.originalImgView.frame.size.width,
                              self.currentOriginalImage.size.height / self.originalImgView.frame.size.height);
    NSLog(@"Scale[%f][%f]",scale.width,scale.height);
    CGPoint locationInView = CGPointMake(self.gridContainerView.frame.origin.x - self.originalImgView.frame.origin.x, self.gridContainerView.frame.origin.y - self.originalImgView.frame.origin.y);
    NSLog(@"location In View[%f][%f]",locationInView.x,locationInView.y);
    CGPoint locationInImage = CGPointMake(locationInView.x * scale.width, locationInView.y * scale.height);
    NSLog(@"location In Image[%f][%f]",locationInImage.x,locationInImage.y);
    CGSize  sizeInImage = CGSizeMake(self.gridContainerView.frame.size.width * scale.width,self.gridContainerView.frame.size.height * scale.height);
    NSLog(@"size In Image[%f][%f]",sizeInImage.width,sizeInImage.height);

    UIImage *tempImage = [self.currentOriginalImage croppedImageWithRect:CGRectMake(locationInImage.x, locationInImage.y,sizeInImage.width,sizeInImage.height)];
    self.currentOriginalImage = [tempImage resizedImageWithMinimumSize:SC_CROP_PHOTO_SIZE];
    //UIImageWriteToSavedPhotosAlbum(self.currentOriginalImage, nil, nil, nil);
    tempImage = nil;
    return self.currentOriginalImage;
}

#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
    self.currentOriginalImage = nil;
    self.data = nil;
    self.delegate = nil;
    
}

@end
