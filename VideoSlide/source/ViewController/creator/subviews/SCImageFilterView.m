//
//  SCImageFilterView.m
//  SlideshowCreator
//
//  Created 10/14/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCImageFilterView.h"

@interface SCImageFilterView ()

@property (nonatomic, strong) SCSlideComposition                *slide;
@property (nonatomic, strong) IBOutlet UIImageView              *imageView;
@property (nonatomic, strong) IBOutlet UIScrollView             *filterModeScrollView;

@property (nonatomic, assign) SCImageFilterMode                 originalImageFilterMode;

@property (nonatomic, strong) NSMutableArray                    *buttonArray;
@property (nonatomic, strong) NSMutableArray                    *selectedBarArray;
@property (nonatomic, strong) NSMutableArray                    *labelArray;

- (IBAction)onDone:(id)sender;

@end

@implementation SCImageFilterView
//@synthesize gpuFilterCamera;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"SCImageFilterView" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        self.buttonArray = [[NSMutableArray alloc] init];
        self.selectedBarArray = [[NSMutableArray alloc] init];
        self.labelArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)hidePreviewfilterImageWith:(void (^)(void))completionBlock
{
    if(self.photoImgView.superview)
    {
        [UIView  animateWithDuration:0.001 animations:^
         {
             self.photoImgView.alpha = 0;
         }completion:^(BOOL finished) {
             [self.photoImgView removeFromSuperview];
             self.photoImgView.alpha = 1;
             completionBlock();
         }];
    }
}

#pragma mark - actions

- (IBAction)onDone:(id)sender
{
    [self moveDownWithCompletion:^{
        if([self.delegate respondsToSelector:@selector(didFinishSettingFilterWithChanged:)])
        {
            [self.delegate didFinishSettingFilterWithChanged:YES];
        }
        [self removeFromSuperview];
        //[self.photoImgView removeFromSuperview];
    }];
}

#pragma mark - instance methods
- (void)updateWith:(SCSlideComposition*)slide
{
    self.slide = slide;
    if(self.slide.filterComposition.filteredImage)
    {
        self.photoImgView.image = self.slide.filterComposition.filteredImage;
    }
    else
    {
        self.photoImgView.image = self.slide.image;
    }
    
    [self resetUIState];
    [self changeFilterUIAtIndex:self.slide.filterComposition.filterMode];

    [self focusOnSelectedFilterModeIndex:self.slide.filterComposition.filterMode];
    
    if(self.slide.image)
    {
        self.originalImageFilterMode = self.slide.filterComposition.filterMode;
        
        [self loadFilterModeView];
    }
}

#pragma mark - Filter mode scroll view
- (void)loadFilterModeView {
    
    [self.buttonArray removeAllObjects];
    [self.selectedBarArray removeAllObjects];
    [self.labelArray removeAllObjects];
    
    for (UIView *v in self.filterModeScrollView.subviews) {
        if (![v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
        }
    }
    
    for (int i = 0; i < SC_TOTAL_FILTER_MODE; i++) {
        
        UIView *filterModeHolderView = [[UIView alloc] initWithFrame:CGRectMake(i*80, 14, 80, 80)];
        
        UIButton *filterModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [filterModeBtn setImage:[self imageFilterMode:i] forState:UIControlStateNormal];
        filterModeBtn.tag = i;
        [filterModeBtn addTarget:self action:@selector(onSelectFilter:) forControlEvents:UIControlEventTouchUpInside];
        [filterModeHolderView addSubview:filterModeBtn];
        
        UILabel *filterModeLb = [[UILabel alloc] init];
        filterModeLb.text = [self nameFilterMode:i];
        filterModeLb.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        filterModeLb.textAlignment = NSTextAlignmentCenter;
        [filterModeHolderView addSubview:filterModeLb];
        
        UIImageView *selectedBarImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image_filterview_selected_bar.png"]];
        selectedBarImgView.frame = CGRectMake(23, 62, 34, 5);
        selectedBarImgView.hidden = YES;
        [filterModeHolderView addSubview:selectedBarImgView];
        
        [self.filterModeScrollView addSubview:filterModeHolderView];
        
        [self.buttonArray addObject:filterModeBtn];
        [self.labelArray addObject:filterModeLb];
        [self.selectedBarArray addObject:selectedBarImgView];
    }
    
    [self resetUIState];
    [self changeFilterUIAtIndex:self.slide.filterComposition.filterMode];

    self.filterModeScrollView.contentSize = CGSizeMake(SC_TOTAL_FILTER_MODE*80, 108);
    
}

- (UIImage*)imageFilterMode:(SCImageFilterMode)filterMode {
    switch (filterMode) {
        case SCImageFilterModeNormal:
            return [UIImage imageNamed:@"image_filter_mode_normal.png"];
            break;
        case SCImageFilterModeOne:
            return [UIImage imageNamed:@"image_filter_mode_one.png"];
            break;
        case SCImageFilterModeTwo:
            return [UIImage imageNamed:@"image_filter_mode_two.png"];
            break;
        case SCImageFilterModeThree:
            return [UIImage imageNamed:@"image_filter_mode_three.png"];
            break;
        case SCImageFilterModeFour:
            return [UIImage imageNamed:@"image_filter_mode_four.png"];
            break;
        case SCImageFilterModeFive:
            return [UIImage imageNamed:@"image_filter_mode_five.png"];
            break;
        case SCImageFilterModeSix:
            return [UIImage imageNamed:@"image_filter_mode_six.png"];
            break;
        case SCImageFilterModeSeven:
            return [UIImage imageNamed:@"image_filter_mode_seven.png"];
            break;
        case SCImageFilterModeEight:
            return [UIImage imageNamed:@"image_filter_mode_eight.png"];
            break;
        case SCImageFilterModeNine:
            return [UIImage imageNamed:@"image_filter_mode_nine.png"];
            break;
        case SCImageFilterModeTen:
            return [UIImage imageNamed:@"image_filter_mode_ten.png"];
            break;
        case SCImageFilterModeEleven:
            return [UIImage imageNamed:@"image_filter_mode_eleven.png"];
            break;
        case SCImageFilterModeTwelve:
            return [UIImage imageNamed:@"image_filter_mode_twelve.png"];
            break;
        case SCImageFilterModeThirteen:
            return [UIImage imageNamed:@"image_filter_mode_thirteen.png"];
            break;
        case SCImageFilterModeFourteen:
            return [UIImage imageNamed:@"image_filter_mode_fourteen.png"];
            break;
        case SCImageFilterModeFifteen:
            return [UIImage imageNamed:@"image_filter_mode_fifteen.png"];
            break;
        default:
            break;
    }
}

- (NSString*)nameFilterMode:(SCImageFilterMode)filterMode {
    switch (filterMode) {
        case SCImageFilterModeNormal:
            return @"Normal";
            break;
        case SCImageFilterModeOne:
            return @"One";
            break;
        case SCImageFilterModeTwo:
            return @"Two";
            break;
        case SCImageFilterModeThree:
            return @"Three";
            break;
        case SCImageFilterModeFour:
            return @"Four";
            break;
        case SCImageFilterModeFive:
            return @"Five";
            break;
        case SCImageFilterModeSix:
            return @"Six";
            break;
        case SCImageFilterModeSeven:
            return @"Seven";
            break;
        case SCImageFilterModeEight:
            return @"Eight";
            break;
        case SCImageFilterModeNine:
            return @"Nine";
            break;
        case SCImageFilterModeTen:
            return @"Ten";
            break;
        case SCImageFilterModeEleven:
            return @"Eleven";
            break;
        case SCImageFilterModeTwelve:
            return @"Twelve";
            break;
        case SCImageFilterModeThirteen:
            return @"Thirteen";
            break;
        case SCImageFilterModeFourteen:
            return @"Fourteen";
            break;
        case SCImageFilterModeFifteen:
            return @"Fifteen";
            break;
        default:
            break;
    }
}

- (void)onSelectFilter:(id)sender {

    int tagFilter = ((UIButton*)sender).tag;
    
    if (self.slide.filterComposition.filterMode == tagFilter) {
        return;
    } else {
        [self resetUIState];
        [self changeFilterUIAtIndex:tagFilter];
    }
    self.slide.filterComposition.hasFilterChanged = YES;
    self.slide.needToUpdate = YES;

    switch (tagFilter) {
        case SCImageFilterModeNormal:
            self.slide.filterComposition.filterMode = SCImageFilterModeNormal;
            [self filterNormal];
            break;
        case SCImageFilterModeOne:
            self.slide.filterComposition.filterMode = SCImageFilterModeOne;
            [self filterWithName:@"02"];
            break;
        case SCImageFilterModeTwo:
            self.slide.filterComposition.filterMode = SCImageFilterModeTwo;
            [self filterWithName:@"06"];
            break;
        case SCImageFilterModeThree:
            self.slide.filterComposition.filterMode = SCImageFilterModeThree;
            [self filterWithName:@"17"];
            break;
        case SCImageFilterModeFour:
            self.slide.filterComposition.filterMode = SCImageFilterModeFour;
            [self filterWithName:@"aqua"];
            break;
        case SCImageFilterModeFive:
            self.slide.filterComposition.filterMode = SCImageFilterModeFive;
            [self filterWithName:@"Country"];
            break;
        case SCImageFilterModeSix:
            self.slide.filterComposition.filterMode = SCImageFilterModeSix;
            [self filterWithName:@"desert"];
            break;
        case SCImageFilterModeSeven:
            self.slide.filterComposition.filterMode = SCImageFilterModeSeven;
            [self filterWithName:@"Brannan"];
            break;
        case SCImageFilterModeEight:
            self.slide.filterComposition.filterMode = SCImageFilterModeEight;
            [self filterWithName:@"fogy_blue"];
            break;
        case SCImageFilterModeNine:
            self.slide.filterComposition.filterMode = SCImageFilterModeNine;
            [self filterWithName:@"pink"];
            break;
        case SCImageFilterModeTen:
            self.slide.filterComposition.filterMode = SCImageFilterModeTen;
            [self filterWithName:@"purple-green"];
            break;
        case SCImageFilterModeEleven:
            self.slide.filterComposition.filterMode = SCImageFilterModeEleven;
            [self filterWithName:@"yellow-blue"];
            break;
        case SCImageFilterModeTwelve:
            self.slide.filterComposition.filterMode = SCImageFilterModeTwelve;
            [self filterWithName:@"yellow-blue6"];
            break;
        case SCImageFilterModeThirteen:
            self.slide.filterComposition.filterMode = SCImageFilterModeThirteen;
            [self filterWithName:@"yellow"];
            break;
        case SCImageFilterModeFourteen:
            self.slide.filterComposition.filterMode = SCImageFilterModeFourteen;
            [self filterWithName:@"creamy"];
            break;
        case SCImageFilterModeFifteen:
            self.slide.filterComposition.filterMode = SCImageFilterModeFifteen;
            [self filterWithName:@"dark_green"];
            break;
        default:
            break;
    }
    if([self.delegate respondsToSelector:@selector(didSelectedFilterOnSlideComposition:)])
    {
        [self.delegate didSelectedFilterOnSlideComposition:self.slide];
    }
}

- (void)filterWithName:(NSString*)filterName {
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:self.slide.image];
    
    GPUImageToneCurveFilter *stillImageFilter =  [[GPUImageToneCurveFilter alloc] initWithACV:filterName];
    [stillImageSource addTarget:stillImageFilter];
    [stillImageSource processImage];
    
    UIImage *filted = [stillImageFilter imageFromCurrentlyProcessedOutput];
    self.photoImgView.image = filted;
    self.slide.filterComposition.filteredImage = filted;
    self.slide.filterComposition.thumbnailFilteredImage = [SCImageUtil imageWithImage:self.slide.filterComposition.filteredImage scaledToSize:SC_THUMBNAIL_IMAGE_SIZE];
    
}

- (void)filterNormal {
    self.photoImgView.image = self.slide.image;
    self.slide.filterComposition.filteredImage = nil;
    self.slide.filterComposition.thumbnailFilteredImage = nil;
}

#pragma mark - UI Change methods
- (void)resetUIState {
    
    if (self.buttonArray.count == 0) {
        return;
    }
    
    for (int i = 0; i < SC_TOTAL_FILTER_MODE; i++) {
        UIButton *button = (UIButton*)[self.buttonArray objectAtIndex:i];
        button.frame = CGRectMake(12, 5, 56, 56);
        button.layer.cornerRadius = 6.0f;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        button.layer.masksToBounds = YES;
        
        UILabel *label = (UILabel*)[self.labelArray objectAtIndex:i];
        label.frame = CGRectMake(0, 68, 80, 20);
        label.textColor = [UIColor blackColor];
        
        UIImageView *barImageView = (UIImageView*)[self.selectedBarArray objectAtIndex:i];
        barImageView.hidden = YES;
    }
}

- (void)changeFilterUIAtIndex:(int)i {
    
    if (self.buttonArray.count == 0) {
        return;
    }
    
    UIButton *button = (UIButton*)[self.buttonArray objectAtIndex:i];
    button.frame = CGRectMake(12, 5 - 10, 56, 56);
    button.layer.cornerRadius = 6.0f;
    button.layer.borderWidth = 1.0;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor colorWithRed:52.0/255.0 green:170.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;
    
    UILabel *label = (UILabel*)[self.labelArray objectAtIndex:i];
    label.frame = CGRectMake(0, 68, 80, 20);
    label.textColor = [UIColor colorWithRed:254.0/255.0 green:70.0/255.0 blue:105.0/255.0 alpha:1.0];
    
//    UIImageView *barImageView = (UIImageView*)[self.selectedBarArray objectAtIndex:i];
//    barImageView.hidden = NO;
}

- (void)focusOnSelectedFilterModeIndex:(int)i {
    // Scroll filter mode scroll view to current selected filter mode.
    CGPoint pointScrollTo;
    //if ((i == 0) || (i == 1)) {
    //    pointScrollTo = CGPointMake(i*80, 0);
    //}// else if ((i > 1) && (i < (SC_TOTAL_FILTER_MODE - 2))) {
    //    pointScrollTo = CGPointMake((i*80) + (80*2), 0);
    //}
    

    if (i < 2) {
        pointScrollTo = CGPointMake(0, 0);
    }
     else if ((i < (SC_TOTAL_FILTER_MODE - 2)) && (i > 1)) {
         pointScrollTo = CGPointMake(i*80 + 40 - 160, 0);
     }
     else if (i >= (SC_TOTAL_FILTER_MODE - 2)) {
         pointScrollTo = CGPointMake(self.filterModeScrollView.contentSize.width - (80*4), 0);
     }
     [self.filterModeScrollView setContentOffset:pointScrollTo animated:YES];
}

#pragma mark - clear

- (void)clearAll
{
    [super clearAll];
    self.delegate = nil;
}

@end
