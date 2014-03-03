//
//  SCGalleryViewController.m
//  SlideshowCreator
//
//  Created 10/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCGalleryViewController.h"

@interface SCGalleryViewController () <SCItemGridViewProtocol, MBProgressHUDDelegate>

@property (nonatomic, strong) IBOutlet SCView *itemView;
@property (nonatomic, strong) SCItemGridView *gridView;
@property (nonatomic, strong) NSMutableArray *slideShowData;
@property (nonatomic, strong) NSMutableArray *thumbnails;
@property (nonatomic, strong) MBProgressHUD  *progressHUD;


- (IBAction)onBackBtn:(id)sender;

- (void)showProgressHUDWithType:(MBProgressHUDMode)type andMessage:(NSString*)message;
- (void)hideProgressHUD;
- (void)loadAllSlideShowDataWithSuccessHandler:(void (^)(void))completionBlock;
@end

@implementation SCGalleryViewController

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
    self.gridView = [[SCItemGridView alloc] initWith:self.itemView.frame
                                             andType:SCGridViewTypeLargeVertical
                                   numberItemPerPage:self.slideShowData.count];
    
    [self.gridView setDelegate:self];
    //notice that grid view is using static data
    [self.gridView setIsUsingDynamicData:NO];
    //add to View
    [self.view addSubview:self.gridView];
    
    [self loadAllSlideShowDataWithSuccessHandler:^{
        //do something here after load all projects
    }];
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

- (void)viewActionAfterTurningBack
{
    [super viewActionAfterTurningBack];
    [self loadAllSlideShowDataWithSuccessHandler:^
    {
    }];
}


#pragma mark - ibactions
- (IBAction)onBackBtn:(id)sender
{
    [self goBack];
}


#pragma mark - class methods

- (void)loadAllSlideShowDataWithSuccessHandler:(void (^)(void))completionBlock
{
    [self.itemView showLoading];
    [self.gridView setHidden:YES];
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
            [self.gridView setHidden:NO];
            self.gridView.alpha = 0;
            [self.gridView setData:self.slideShowData];
            [UIView animateWithDuration:0.3 animations:^{
                self.gridView.alpha = 1;
            } completion:^(BOOL finished) {
            }];
            [self.itemView hideLoading];
            completionBlock();
        });
    });
    
}


#pragma mark - item grid view

- (void)SCitemGridView:(SCItemGridView *)itemGridView loadDataAtfirstTimeWith:(int)numberPage
{
    if(itemGridView.data.count == 0)
    {
        [self.gridView setData:self.self.slideShowData];
    }
}

- (SCItemGridViewCell *)SCitemGridView:(SCItemGridView *)itemGridView cellForItemAtIndex:(int)index
{
    SCGalleryItemCell *cell = (SCGalleryItemCell*)[itemGridView.gridView dequeueReusableCellWithIdentifier:@"SCGalleryItemCell"];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SCGalleryItemCell" owner:self options:nil] objectAtIndex:0];
    }
    
    if(self.slideShowData.count > index)
    {
        SCSlideShowModel *slideShow = (SCSlideShowModel*)[self.slideShowData objectAtIndex:index];
        UIImage *image = [self.thumbnails objectAtIndex:index];
        [cell updateWithData:slideShow thumbnail:image];
    }
    
    return cell;
    
}

- (CGSize)sizeForItemCell
{
    return SC_PROJECT_ITEM_SIZE;
}


- (void)SCitemGridView:(SCItemGridView *)itemGridView didSelectItemAtIndex:(int)index withCell:(SCItemGridViewCell *)cell {
    // display checkmark icon
    
    NSMutableDictionary *transit = [[NSMutableDictionary alloc] init];
    
    [transit setObject:self.slideShowData forKey:SC_TRANSIT_KEY_SLIDE_SHOW_MODEL_ARRAY_DATA];
    [transit setObject:[NSNumber numberWithInt:index] forKey:SC_TRANSIT_KEY_SLIDE_SHOW_INDEX];
    [transit setObject:self.thumbnails forKey:SC_TRANSIT_KEY_SLIDE_SHOW_THUMBNAIL_ARRAY];

    [self gotoScreen:SCEnumProjectDetailScreen data:transit];
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

#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
    if(self.gridView)
    {
        [self.gridView clearAll];
        self.gridView = nil;
    }
    if(self.progressHUD)
    {
        self.progressHUD.delegate = self;
    }
        
    if(self.thumbnails.count > 0 )
    {
        [self.thumbnails removeAllObjects];
    }
    
    self.thumbnails = nil;
}



@end
