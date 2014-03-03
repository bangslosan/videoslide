//
//  SCCreatorTestViewController.m
//  SlideshowCreator
//
//  Created 9/5/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCCreatorTestViewController.h"
#import "AppDelegate.h"

@interface SCCreatorTestViewController () <UIAlertViewDelegate, SCMediaExporterProtocol,MBProgressHUDDelegate, SCItemGridViewProtocol,GMGridViewDataSource, GMGridViewSortingDelegate, GMGridViewTransformationDelegate, GMGridViewActionDelegate>

@property (nonatomic, strong) IBOutlet UITextField *captionTf;
@property (nonatomic, strong) IBOutlet UITextField *slideDurationTf;
@property (nonatomic, strong) IBOutlet UIScrollView *timeLineScrollView;
@property (nonatomic, strong) IBOutlet UIView       *timeLineContentView;
@property (nonatomic, strong) SCPreviewer           *previewer;
@property (nonatomic, strong) GMGridView        *gridView;

@property (nonatomic, strong) NSMutableArray        *images;


@property (nonatomic, strong) NSString *resultName;
@property (nonatomic, strong) SCSlideShowComposition    *slideShowComposition;
@property (nonatomic, strong) SCMediaExporter           *exporter;
@property (nonatomic, strong) MBProgressHUD             *progressHUD;

- (IBAction)onCreate:(id)sender;
- (IBAction)onGallerry:(id)sender;
- (IBAction)onPlay:(id)sender;
- (IBAction)onReset:(id)sender;
- (IBAction)onPreview:(id)sender;


@end

@implementation SCCreatorTestViewController

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
    //[SCTestUtil convertImageToVideo];
   /* self.gridView = [[SCItemGridView alloc] initWith:self.view.bounds andType:SCGridViewItemTypeVertical numberItemPerPage:100];
    self.gridView.delegate = self;
    self.gridView.gridView.backgroundColor = [UIColor redColor];*/
    
    
    NSInteger spacing =  3;
    
    self.gridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.gridView.backgroundColor = [UIColor redColor];
    self.gridView.clipsToBounds = YES;
    
     self.gridView.style = GMGridViewStylePush;
    self.gridView.itemSpacing = spacing;
    self.gridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    self.gridView.centerGrid = NO;
    self.gridView.actionDelegate = self;
    self.gridView.sortingDelegate = self;
//    self.gridView.transformDelegate = self;
    self.gridView.dataSource = self;
    self.gridView.mainSuperView  =self.view;
    
    [self.view addSubview:self.gridView];
    [self.gridView reloadData];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return 100;//[self.slideShowComposition.slides count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(75, 75);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    //NSLog(@"Creating view indx %d", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
         cell = [[GMGridViewCell alloc] init];
         cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
         cell.deleteButtonOffset = CGPointMake(-15, -15);
         
         UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
         view.backgroundColor = [UIColor blueColor];
         view.layer.masksToBounds = NO;
         view.layer.cornerRadius = 8;
         
         cell.contentView = view;
       // cell = [[[NSBundle mainBundle] loadNibNamed:@"SCPhotoItemView" owner:self options:nil] objectAtIndex:0];
    }
    
    /*[[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
     
     UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
     label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
     label.text = (NSString *)[_currentData objectAtIndex:index];
     label.textAlignment = UITextAlignmentCenter;
     label.backgroundColor = [UIColor clearColor];
     label.textColor = [UIColor blackColor];
     label.highlightedTextColor = [UIColor whiteColor];
     label.font = [UIFont boldSystemFontOfSize:20];
     [cell.contentView addSubview:label];*/
    
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSLog(@"Did tap at index %d", position);
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewSortingDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor orangeColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];
}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor blueColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return YES;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
   // NSObject *object = [_currentData objectAtIndex:oldIndex];
   // [_currentData removeObject:object];
   // [_currentData insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    //[_currentData exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}



#pragma mark - gridView delegate

- (SCItemGridViewCell *)SCitemGridView:(SCItemGridView *)itemGridView cellForItemAtIndex:(int)index
{
    SCPhotoItemView *cell = (SCPhotoItemView*)[itemGridView.gridView dequeueReusableCellWithIdentifier:@"SCItemGridViewCell"];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SCPhotoItemView" owner:self options:nil] objectAtIndex:0];
    }
    
    SCSlideComposition *slideComposition = (SCSlideComposition*)[self.slideShowComposition.slides objectAtIndex:index];
    cell.photoImgView.image = slideComposition.image;
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
        //[self.gridView setData:self.slideShowComposition.slides];
    }
}

#pragma mark - actions
- (IBAction)onPreview:(id)sender
{
    if(!self.slideShowComposition)
        return;
    if(self.previewer)
    {
        [self.previewer removeFromSuperview];
        self.previewer = nil;
    }
    
    [self onReset:nil];
    if(self.slideShowComposition.videos.count > 0)
    {
        if(self.slideShowComposition)
        {
            if(!self.previewer)
            {
                SCAdvancedMediaBuilder *builder = [[SCAdvancedMediaBuilder alloc] initWithSlideShow:self.slideShowComposition];
                self.previewer = [SCPreviewer initWithAdvanced:[builder buildMediaComposition]];
            }
            if(!self.previewer.superview)
            {
                [self.view addSubview:self.previewer];
            }
        }
    }
    else
    {
        if(!self.progressHUD)
        {
            self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.progressHUD];
            self.progressHUD.delegate = self;
            self.progressHUD.labelText = @"Composing...";
        }
        [self.progressHUD show:YES];
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            //
            //
            [self.slideShowComposition preBuild];
            dispatch_async( dispatch_get_main_queue(), ^{
                // Add code here to update the UI/send notifications based on the
                // results of the background processing
                NSLog(@"Finish");
                [self hudWasHidden:self.progressHUD];
                if(!self.previewer)
                {
                    SCAdvancedMediaBuilder *builder = [[SCAdvancedMediaBuilder alloc] initWithSlideShow:self.slideShowComposition];
                    self.previewer = [SCPreviewer initWithAdvanced:[builder buildMediaComposition]];
                }
                if(!self.previewer.superview)
                {
                    [self.view addSubview:self.previewer];
                }
            });
        });
    }

}

- (IBAction)onPlay:(id)sender
{
    [[SCScreenManager getInstance] playMovieWithUrl:[SCFileManager URLFromTempWithName:self.slideShowComposition.model.name]];
}

- (IBAction)onReset:(id)sender
{
    [SCFileManager deleteAllFileFromDocument];
    [SCFileManager deleteAllFileFromTemp];

}

- (IBAction)onGallerry:(id)sender
{

   /* ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName: nil bundle: nil];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    
    [[SCScreenManager getInstance].rootViewController presentViewController:elcPicker animated:YES completion:nil];*/

}

- (IBAction)onCreate:(id)sender
{
    [self onReset:nil];
    
    if(self.slideShowComposition.videos.count > 0)
    {
        if(self.slideShowComposition)
        {
            //[[SCVideoCreatorManager getInstance] generateVideoWith:self.slideShowComposition];
            if(self.exporter)
            {
                self.exporter = nil;
            }
            self.exporter = [[SCMediaExporter alloc]init];
            self.exporter.delegate = self;
            [self.exporter exportMediaWithSlideShow:self.slideShowComposition];
        }
    }
    else
    {
        if(!self.progressHUD)
        {
            self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.progressHUD];
             self.progressHUD.delegate = self;
             self.progressHUD.labelText = @"Composing...";
        }
        [self.progressHUD show:YES];

        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            //
            //
            [self.slideShowComposition preBuild];
            dispatch_async( dispatch_get_main_queue(), ^{
                // Add code here to update the UI/send notifications based on the
                // results of the background processing
                NSLog(@"Finish");
                [self hudWasHidden:self.progressHUD];
                if(self.slideShowComposition)
                {
                    //[[SCVideoCreatorManager getInstance] generateVideoWith:self.slideShowComposition];
                    if(self.exporter)
                    {
                        self.exporter = nil;
                    }
                    self.exporter = [[SCMediaExporter alloc]init];
                    self.exporter.delegate = self;
                    [self.exporter exportMediaWithSlideShow:self.slideShowComposition];
                }
                
            });
        });
    }
}

#pragma mark ELCImagePickerControllerDelegate Methods

/*- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [[SCScreenManager getInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
		
    if(self.slideShowComposition)
    {
        [self.slideShowComposition clearAll];
        self.slideShowComposition = nil;
    }
    self.slideShowComposition = [[SCSlideShowComposition alloc]init];
    self.slideShowComposition.model.name = [NSString stringWithFormat:@"%@.%@",SC_OUTPUT_VIDEO,SC_MOV];
    self.slideShowComposition.model.videoSize = SC_VIDEO_SIZE;

    int index = 0;
    CGSize size = CGSizeMake(self.timeLineScrollView.frame.size.height, self.timeLineScrollView.frame.size.height);
    
    if(info.count > 0)
    {
        for(UIView *subView in self.timeLineContentView.subviews)
        {
            [subView removeFromSuperview];
            [self.timeLineContentView setFrame:self.timeLineScrollView.bounds];
        }
    }
	for(NSDictionary *dict in info)
    {
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationUp];
        image = [SCImageUtil imageWithImage:image scaledToSize:SC_VIDEO_SIZE];
        float duration = 1;
        if(image)
        {
            int i = 0;
            while (i < 20)
            {
                
            
                //create time line
                UIImageView *imgView = [[UIImageView alloc]initWithImage:image];
                [imgView setFrame:CGRectMake(size.width * index, 0, size.width, size.height)];
                [self.timeLineContentView addSubview:imgView];
                [self.timeLineContentView setFrame:CGRectMake(0, 0, (index + 1)*size.width, size.height)];
                [self.timeLineScrollView setContentSize:self.timeLineContentView.frame.size];
                SCSlideComposition *slideCom = [[SCSlideComposition alloc] initWithImage:image startTransTime:1 endTransTime:1 duration:duration];
                
                
                slideCom.model.duration = CMTimeGetSeconds(SC_DEFAULT_TRANSITION_DURATION) * 2 + duration ;
                slideCom.model.name = [NSString stringWithFormat:@"image%d.png",index];
    //            
    //            slideCom.model.beginDisplay = [[SCTransitionModel alloc]init];
    //            slideCom.model.beginDisplay.name = @"opacity";
    //            slideCom.model.beginDisplay.duration = 1;
    //            
    //            slideCom.model.endDisplay = [[SCTransitionModel alloc]init];
    //            slideCom.model.endDisplay.name = @"opacity";
    //            slideCom.model.endDisplay.duration = 1;
                [self.slideShowComposition addSlideComposition:slideCom];
                i++;
                index++;
            }
        }
    
    }
    //add transitions
    if(self.slideShowComposition.slides.count >= 2)
    {
        for(int i = 0; i <= self.slideShowComposition.slides.count - 2; i++)
        {
            //create transition
            //SCTransitionComposition *trans = [SCTransitionComposition disolveTransitionWithDuration:SC_DEFAULT_TRANSITION_DURATION];
            SCTransitionComposition *trans = [SCTransitionComposition pushTransitionWithDuration:SC_DEFAULT_TRANSITION_DURATION_SECOND direction:SCPushTransitionDirectionRightToLeft];
            //SCTransitionComposition *trans = [SCTransitionComposition zoomTransitionWithDuration:SC_DEFAULT_TRANSITION_DURATION];
            [self.slideShowComposition addTransitionAfterSlideIndex:i transition:trans];
        }
    }
    
    // add music
    SCAudioComposition *musicItem = [SCAudioComposition audioCompositionWithURL:[[NSBundle mainBundle] URLForResource:[SC_AUDIO_DEMO_1 stringByDeletingPathExtension] withExtension:SC_WAV] fadeInTime:4 fadeOutTime:4];
    [self.slideShowComposition.musics addObject:musicItem];
    
    // add audio
    SCAudioComposition *audioItem = [SCAudioComposition audioCompositionWithURL:[[NSBundle mainBundle] URLForResource:[SC_AUDIO_DEMO_2 stringByDeletingPathExtension] withExtension:SC_WAV] fadeInTime:0 fadeOutTime:0];
    [self.slideShowComposition.audios addObject:audioItem];
    
    //create image slide show model
    UIAlertView *alert = [[UIAlertView alloc]  initWithTitle:@"Asset Loaded" message:@"Start Create video ?"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel",nil];
    //[alert show];
    
    [self.view addSubview:self.gridView];
    [self.gridView reloadData];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [[SCScreenManager getInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
}*/




#pragma mark - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self onCreate:nil];
    }
}

#pragma mark - exporter delegate

- (void)didFinishExportVideoWithSuccess:(BOOL)status
{
    if(status)
    {
        
    }
    else
    {
        
    }
}

- (void)percentOfExportProgress:(float)percent
{
    if(!self.progressHUD)
    {
        self.progressHUD = [[MBProgressHUD alloc] initWithView:[SCScreenManager getInstance].rootViewController.view];
        [self.navigationController.view addSubview:self.progressHUD];
        
        // Set determinate bar mode
        self.progressHUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
        self.progressHUD.delegate = self;
        [self.progressHUD show:YES];
    }
    
    self.progressHUD.progress = percent;
    if(percent >= 1)
    {
        [self hudWasHidden:self.progressHUD];
    }
    
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[self.progressHUD removeFromSuperview];
	self.progressHUD = nil;
}

@end



