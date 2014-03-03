//
//  SCVideoEditorViewController.m
//  SlideshowCreator
//
//  Created 9/10/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCVideoEditorViewController.h"

@interface SCVideoEditorViewController ()   <UIScrollViewDelegate,
                                            SCSlideShowCompositionProtocol,
                                            SCSlideShowPreviewProtocol,
                                            MBProgressHUDDelegate,
                                            SCSoundTrackViewProtocol,
                                            SCMediaTimeLineViewProtocol,
                                            SCAudioRecordViewProtocol,
                                            SCDurationSettingViewProtocol,
                                            SCImageFilterViewProtocol>


@property (nonatomic, strong) IBOutlet UIView           *topPanelView;
@property (nonatomic, strong) IBOutlet UIView           *toolBarPanelView;
@property (nonatomic, strong) IBOutlet UIScrollView     *timeLinePanelView;
@property (nonatomic, strong) IBOutlet UIView           *timeLinePanelContentView;
@property (nonatomic, strong) IBOutlet UIView           *previewView;
@property (nonatomic, strong) IBOutlet UIView           *textEditView;
@property (nonatomic, strong) IBOutlet UIView           *contextMenuView;
@property (nonatomic, strong) IBOutlet UIView           *currentSubView;

@property (nonatomic, strong) IBOutlet UIImageView      *stylusImgView;
@property (nonatomic, strong) IBOutlet UIImageView      *currentSelectedSlideImgView;

@property (nonatomic, strong) IBOutlet UIButton         *backBtn;
@property (nonatomic, strong) IBOutlet UIButton         *durationSettingBtn;
@property (nonatomic, strong) IBOutlet UIButton         *helpBtn;


@property (nonatomic, strong) IBOutlet UIButton         *playBtn;
@property (nonatomic, strong) IBOutlet UIButton         *filterBtn;
@property (nonatomic, strong) IBOutlet UIButton         *addBtn;
@property (nonatomic, strong) IBOutlet UIButton         *exportBtn;
@property (nonatomic, strong) UIButton                  *contextMenuCloseBtn;


@property (nonatomic, strong) SCMediaTimeLineView       *mediaTimeLineView;
@property (nonatomic, strong) SCSlideShowPreview        *slideShowPreView;
@property (nonatomic, strong) SCPreviewer               *previewer;
@property (nonatomic, strong) SCSoundTrackView          *soundTrackView;
@property (nonatomic, strong) SCAudioRecordView         *recordView;
@property (nonatomic, strong) SCImageFilterView         *imageFilterView;
@property (nonatomic, strong) SCDurationSettingView     *durationSettingView;


@property (nonatomic, strong) SCSlideShowComposition    *slideShowComposition;
@property (nonatomic, strong) SCSlideShowModel          *model;
@property (nonatomic, strong) SCBasicBuilderComposition *builderComposition;


@property (nonatomic, strong) MBProgressHUD             *progressHUD;
@property (nonatomic, strong) NSTimer                   *sliderTimer;
@property (nonatomic, strong) NSTimer                   *progressTimer;
@property (nonatomic, strong) NSTimer                   *autoScrollTimer;

@property (nonatomic, strong) UITapGestureRecognizer    *tapGesture;

@property (nonatomic)         float                     currentTimeBeforeRecording;
@property (nonatomic)         BOOL                      timeLineIsScrolling;
@property (nonatomic)         BOOL                      firstTime;
@property (nonatomic)         BOOL                      lastPlaying;
@property (nonatomic)         BOOL                      needToUpdateDurationSetting;


- (IBAction)onBackBtn:(id)sender;
- (IBAction)onVideoSettingBtn:(id)sender;
- (IBAction)onHelpBtn:(id)sender;
- (IBAction)onFilterBtn:(id)sender;
- (IBAction)onAddBtn:(id)sender;
- (IBAction)onPlayBtn:(id)sender;
- (IBAction)onExportBtn:(id)sender;

- (IBAction)onAddPhoto:(id)sender;
- (IBAction)onAddSoundTrack:(id)sender;
- (IBAction)onAddAudioRecord:(id)sender;
- (IBAction)onAddText:(id)sender;

- (void)initTimeLinePanel;
- (void)initPreViewPanel;
- (void)initTextEditorView;
- (void)initDurationSetting;
- (void)initImageFilterView;
- (void)initMusicEditor;

- (void)updateTextLayer;
- (void)resetEditorWithSlideShowCompositionWithSuccess:(void (^)(void))completionBlock;
- (void)gotoProgressPosition:(float)position;
- (void)playPreview;
- (void)pausePreview;
- (void)setToolbarHidden:(BOOL)hide;
- (void)showProgressHUDWithType:(MBProgressHUDMode)type andMessage:(NSString*)message;
- (void)hideProgressHUD;
- (void)hideTopControl:(BOOL)hide;
- (void)updateDurationSettingIcon;
- (void)clearTextLayerView;

- (float)currentTimeLineProgress;
- (SCBasicBuilderComposition*)createBuilderComposition;
- (SCSlideComposition*)currentSelectedSlide;

@end

@implementation SCVideoEditorViewController

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
    //get data from last screen
    //init slideshow
    [self showProgressHUDWithType:MBProgressHUDModeIndeterminate andMessage:NSLocalizedString(@"processing", nil)];
    self.needToUpdateDurationSetting = NO;
    self.model = [self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_SHOW_COMPOSITION_MODEL];
    if(self.model)
    {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.slideShowComposition = [[SCSlideShowComposition alloc] initWithModel:self.model];
            self.slideShowComposition.delegate = self;
            [self.slideShowComposition updateSLideShowSetting];
            dispatch_async( dispatch_get_main_queue(), ^{
                //get data from project detail
                [self resetEditorWithSlideShowCompositionWithSuccess:^
                 {
                 }];
            });
        });
    }
    else if([SCSlideShowSettingManager getInstance].slideShowComposition)
    {
        self.slideShowComposition = [SCSlideShowSettingManager getInstance].slideShowComposition;
        self.slideShowComposition.delegate = self;
        [self.slideShowComposition addSlides:[self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_ARRAY]];
        //get data from project detail
        self.needToUpdateDurationSetting = YES;
        [self.slideShowComposition startCropAllPhotos];
    }
    else
    {
        self.slideShowComposition = [[SCSlideShowComposition alloc] init];
        self.slideShowComposition.delegate = self;
        [self.slideShowComposition addSlides:[self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_ARRAY]];
        [[SCSlideShowSettingManager getInstance] setNumberOfPhotos:self.slideShowComposition.slides.count];
        [self.slideShowComposition startCropAllPhotos];
    }
    
    //init text editor view
    [self initTextEditorView];
    
    //init duration setting view
    [self initDurationSetting];
    
    //init image filter view
    [self initImageFilterView];
    
    //do other initialization
    self.contextMenuView.alpha = 0;
    self.timeLinePanelView.clipsToBounds = NO;
    self.timeLinePanelContentView.clipsToBounds = NO;
    
    //create close btn for menu context
    self.contextMenuCloseBtn = [[UIButton alloc] initWithFrame:self.view.bounds];
    self.contextMenuCloseBtn.backgroundColor = [UIColor clearColor];
    [self.contextMenuCloseBtn addTarget:self action:@selector(onCloseContextMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    self.timeLineIsScrolling = NO;
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPreviewDoubleTap:)];
    self.tapGesture.numberOfTapsRequired = 2;
    [self.textEditView addGestureRecognizer:self.tapGesture];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-  (void)viewActionAfterTurningBack
{
    [super viewActionAfterTurningBack];
    if(self.slideShowPreView && self.mediaTimeLineView)
    {
        [self gotoProgressPosition:0];
    }
}

#pragma mark - init methods
- (void)initPreViewPanel
{
    if(!self.slideShowPreView)
    {
        self.slideShowPreView = [[SCSlideShowPreview alloc]initWithBasic:[self createBuilderComposition] frame:self.previewView.bounds];
        self.slideShowPreView.delegate = self;
        [self.previewView addSubview:self.slideShowPreView];
        self.slideShowPreView.frame = self.previewView.bounds;
    }
}

- (void)initTimeLinePanel
{
    if(!self.mediaTimeLineView && self.slideShowComposition)
    {
        self.mediaTimeLineView = [[SCMediaTimeLineView alloc]initWithComposition:self.slideShowComposition];
        self.mediaTimeLineView.delegate  =self;
        self.mediaTimeLineView.mainSuperView = self.timeLinePanelView;
        self.mediaTimeLineView.parentScrollView = self.timeLinePanelView;
        
        //layout the scroll view
        [self.timeLinePanelContentView setFrame:CGRectMake(0, 0, self.timeLinePanelView.frame.size.width + self.mediaTimeLineView.frame.size.width, self.timeLinePanelView.frame.size.height)];
        [self.timeLinePanelView setContentSize:self.timeLinePanelContentView.frame.size];
        [self.timeLinePanelContentView addSubview:self.mediaTimeLineView];
        self.mediaTimeLineView.center = CGPointMake(self.timeLinePanelContentView.frame.size.width/2, self.timeLinePanelContentView.frame.size.height/2);

        //update preview progress width
        [self.slideShowPreView setRealProgressWidth:self.mediaTimeLineView.frame.size.width];
    }
}

- (void)initTextEditorView
{
    
}

- (void)initDurationSetting
{
    if(!self.durationSettingView)
    {
        self.durationSettingView = [[SCDurationSettingView alloc] init];
        self.durationSettingView.frame = CGRectMake(0,self.topPanelView.frame.origin.y,self.durationSettingView.frame.size.width , self.durationSettingView.frame .size.height);
        self.durationSettingView.delegate  = self;
    }
}

- (void)initImageFilterView
{
    if(!self.imageFilterView)
    {
        self.imageFilterView = [[SCImageFilterView alloc] init];
        self.imageFilterView.delegate = self;
        [self.imageFilterView setFrame:CGRectMake(0,
                                                  self.view.frame.size.height -  self.imageFilterView.frame.size.height,
                                                  self.imageFilterView.frame.size.width,
                                                  self.imageFilterView.frame.size.height)];
    }
}

- (void)initMusicEditor
{
    if(!self.soundTrackView)
    {
        self.soundTrackView = [[SCSoundTrackView alloc]init];
        [self.soundTrackView setFrame:CGRectMake(0, self.toolBarPanelView.frame.origin.y, self.soundTrackView.frame.size.width,self.soundTrackView.frame.size.height)];
        self.soundTrackView.delegate = self;
        [self.view addSubview:self.soundTrackView];
        self.soundTrackView.frame = CGRectMake(0, self.view.frame.size.height, self.soundTrackView.frame.size.width, self.soundTrackView.frame.size.height);
    }
}

#pragma mark - actions

- (void)onPreviewDoubleTap:(UIGestureRecognizer*)gesture
{
    [self pausePreview];
    SCSlideComposition *slide = [self.mediaTimeLineView getCurrentSlideWithPosition:self.timeLinePanelView.contentOffset];
    if(slide)
    {
        BOOL showKeyboard = slide.texts.count == 0 ? YES : NO;

        [self.currentSelectedSlideImgView setHidden:NO];
        UIImage *image = slide.filterComposition.filteredImage ? slide.filterComposition.filteredImage : slide.image;
        [self.currentSelectedSlideImgView setImage:image];
    }

}

- (IBAction)onBackBtn:(id)sender
{
    if(self.lastScreen == SCEnumPhotosScreen)
    {
        [SCSlideShowSettingManager getInstance].slideShowComposition = self.slideShowComposition;
    }
    else
    {
        if([SCSlideShowSettingManager getInstance].slideShowComposition)
        {
            [[SCSlideShowSettingManager getInstance].slideShowComposition clearAll];
            [SCSlideShowSettingManager getInstance].slideShowComposition = nil;
        }
        [SCFileManager deleteAllFileFromTemp];
        
        //reset the current slideshow model data when go back to project detail screen
        int index = 0;
        for(SCSlideShowModel *slideShowModel in [SCFileManager getInstance].slideShows)
        {
            if([slideShowModel.name isEqualToString:self.slideShowComposition.model.name])
            {
                NSURL *rootURL = [[SCFileManager getInstance].projects objectAtIndex:index];
                NSURL *projectURL = [SCFileManager urlFromDir:rootURL withName:SC_PROJECT_NAME];
                NSDictionary *itemDict = [[NSDictionary alloc] initWithContentsOfURL:projectURL];
                SCSlideShowModel *model = [[SCSlideShowModel alloc] initWithDictionary:itemDict];
                [[SCFileManager getInstance].slideShows replaceObjectAtIndex:index withObject:model];
                break;
            }
            index ++;
        }

    }
    [self goBack];
}

- (IBAction)onVideoSettingBtn:(id)sender
{
    [self pausePreview];
    [self clearTextLayerView];
    if(!self.durationSettingView.superview)
    {
        if(self.currentSubView)
            return;
        self.currentSubView = self.durationSettingBtn;

        [self.view addSubview:self.durationSettingView];
        [self.durationSettingView updateWithSlideShowSetting];
        [self.durationSettingView fadeInWithCompletion:^
        {
        }];
    }
    else
    {
        [self.durationSettingView fadeOutWithCompletion:^
         {
             [self.durationSettingView removeFromSuperview];
             self.currentSubView = nil;
         }];
    }
}

- (IBAction)onHelpBtn:(id)sender
{
    
}

- (IBAction)onFilterBtn:(id)sender
{
    if(self.currentSubView)
        return;
    self.currentSubView = self.imageFilterView;
    if(!self.imageFilterView.superview)
    {
        SCSlideComposition *slide = [self.mediaTimeLineView getCurrentSlideWithPosition:self.timeLinePanelView.contentOffset];
        if(slide)
        {
            [self.imageFilterView updateWith:slide];
            //pause preview
            [self pausePreview];
            [self.view addSubview:self.imageFilterView];
            [self.imageFilterView moveUpWithCompletion:^
             {
                 if(!self.imageFilterView.photoImgView.superview)
                 {
                     [self.previewView addSubview:self.imageFilterView.photoImgView];
                     self.imageFilterView.photoImgView.frame = self.previewView.bounds;
                     [self.currentSelectedSlideImgView setHidden:YES];
                 }
                [self.imageFilterView updateWith:slide];
                 [self setToolbarHidden:YES];
                 [self hideTopControl:YES];
             }];
        }
    }
}

- (IBAction)onAddBtn:(id)sender
{
    [self clearTextLayerView];
    if(self.contextMenuView.superview)
    {
        [self closeContextMenu];
    }
    else if(!self.contextMenuView.superview)
    {
        [self openContextMenu];
    }
}

- (void)closeContextMenu
{
    self.currentSubView = nil;
    self.contextMenuView.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^
     {
         self.contextMenuView.alpha = 0;
     }completion:^(BOOL finished)
     {
         [self.contextMenuView removeFromSuperview];
         if(self.contextMenuCloseBtn.superview)
         {
             [self.contextMenuCloseBtn removeFromSuperview];
         }
     }];
}

- (void)openContextMenu
{
    if(self.currentSubView)
        return;
    self.currentSubView = self.contextMenuView;

    if(!self.contextMenuCloseBtn.superview)
    {
        [self.view addSubview:self.contextMenuCloseBtn];
    }
    [self.view addSubview:self.contextMenuView];
    self.contextMenuView.frame = CGRectMake(0, self.toolBarPanelView.frame.origin.y -  self.contextMenuView.frame.size.height,  self.contextMenuView.frame.size.width,  self.contextMenuView.frame.size.height);
    self.contextMenuView.center = CGPointMake(self.view.frame.size.width/2,  self.contextMenuView.center.y);
    self.contextMenuView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^
     {
         self.contextMenuView.alpha = 1;
     }completion:^(BOOL finished)
     {
     }];
}

- (void)onCloseContextMenu:(id)sender
{
    [self closeContextMenu];

}

- (IBAction)onPlayBtn:(id)sender
{
    if(self.slideShowPreView)
    {
        [self.playBtn setSelected:!self.playBtn.selected];
        {
            if(self.playBtn.isSelected)
            {
                [self playPreview];
            }
            else
            {
                [self pausePreview];
            }
        }
    }
}

- (IBAction)onExportBtn:(id)sender
{
    [self clearTextLayerView];
    [self pausePreview];
    if(self.slideShowComposition)
        [self gotoScreen:SCEnumExportScreen data:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.slideShowComposition,SC_TRANSIT_KEY_SLIDE_SHOW_DATA, nil]];
}

- (IBAction)onAddTextBtn:(id)sender
{
    //pause preview
    [self pausePreview];
}

#pragma mark - context menu action

- (IBAction)onAddPhoto:(id)sender
{
    

}

- (IBAction)onAddSoundTrack:(id)sender
{
    [self onAddBtn:nil];
    [self pausePreview];
    if(!self.soundTrackView)
    {
        self.soundTrackView = [[SCSoundTrackView alloc]init];
        [self.soundTrackView setFrame:CGRectMake(0, self.toolBarPanelView.frame.origin.y, self.soundTrackView.frame.size.width,self.soundTrackView.frame.size.height)];
        self.soundTrackView.delegate = self;
    }
    if(!self.soundTrackView.superview)
    {
        [self.view addSubview:self.soundTrackView];
    }
    if(self.slideShowComposition.musics.count == 0)
        [self.soundTrackView showItunes];
    [self.soundTrackView moveUpWithCompletion:^
     {
         [self hideTopControl:YES];
     }];

}

- (IBAction)onAddAudioRecord:(id)sender
{
    [self onAddBtn:nil];
    
    if(!self.recordView)
    {
        self.recordView = [[SCAudioRecordView alloc]init];
        [self.recordView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.recordView.delegate = self;
    }
    
    if(!self.recordView.superview)
    {
        //pause preview
        [self pausePreview];
        [self.view addSubview:self.recordView];
        //start record audio
        if(self.slideShowComposition.audios.count > 0)
        {
            SCAudioComposition *audioRecord = [self.slideShowComposition.audios objectAtIndex:0];
            self.currentTimeBeforeRecording =  ((CMTimeGetSeconds(self.slideShowComposition.totalDuration) * [self.mediaTimeLineView getCurrentAudioRecordBegin])) / self.mediaTimeLineView.frame.size.width;
            [self.recordView setStartTimeForRecording:self.currentTimeBeforeRecording];
            [self.recordView startEditingAudioWith:audioRecord playBack:NO];
        }
        else
            [self.recordView startRecordingAudio];
        [self.recordView zoomInWithCompletion:^
         {
             [self.recordView setRecordSessionWith:YES];
         }];
    }

}

// from menu context "Add Text"
- (IBAction)onAddText:(id)sender
{
    [self pausePreview];
    [self onAddBtn:nil];
    if([self currentSelectedSlide])
    {
        SCSlideComposition *slide = [self.mediaTimeLineView getCurrentSlideWithPosition:self.timeLinePanelView.contentOffset];
        [self.currentSelectedSlideImgView setHidden:NO];
        UIImage *image = slide.filterComposition.filteredImage ? slide.filterComposition.filteredImage : slide.image;
        
        [self.currentSelectedSlideImgView setImage:image];
    }
    
}

#pragma mark - class methods

- (void)resetEditorWithSlideShowCompositionWithSuccess:(void (^)(void))completionBlock
{
    if(self.slideShowComposition)
    {
        [self gotoProgressPosition:0];
        //update all slide show with slide setting
        if(self.slideShowComposition)
            [self.slideShowComposition refreshSlideShow];
        //[SCFileManager deleteAllfileFromTempWithExtension:SC_MOV];
        [self.slideShowComposition preBuildAsynchronouslyWithCompletionHandler:^
        {
            [self hideProgressHUD];
            if(!self.slideShowPreView && !self.mediaTimeLineView)
            {
                //init preview panel
                [self initPreViewPanel];
                //init time line panel
                [self initTimeLinePanel];
                //update duration setting icon
                [self updateDurationSettingIcon];
            }
            else
            {
                //update preview with new music composition
                [self.slideShowPreView setBasicData:[self createBuilderComposition]];
                
                //update time line with new music time line
                [self.mediaTimeLineView updateTimeLineWith:self.slideShowComposition];
                
                //update duration setting icon
                [self updateDurationSettingIcon];
                [self sliderUpdate:nil];
            }
            
            completionBlock();
        }];
    }
}

- (void)updateTimeLineDataWithSuccess:(void (^)(void))completionBlock
{
    //[self showProgressHUDWithType:MBProgressHUDModeIndeterminate andMessage:nil];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        // //update all compostion and preview playback
        if(self.slideShowPreView && self.mediaTimeLineView)
        {
            //create builder
            if(self.slideShowComposition)
                [self.slideShowComposition refreshSlideShow];
            [self createBuilderComposition];
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            [self hideProgressHUD];
            if(!self.slideShowPreView && !self.mediaTimeLineView)
            {
                //init preview panel
                [self initPreViewPanel];
                //init time line panel
                [self initTimeLinePanel];
                //update duration setting icon
                [self updateDurationSettingIcon];
            }
            else
            {
                //self.slideShowPreView.alpha = 0;
                [self.slideShowPreView setBasicData:self.builderComposition];
                [self sliderUpdate:nil];
                /*[UIView animateWithDuration:0.5 animations:^{
                    self.slideShowPreView.alpha = 1;
                } completion:^(BOOL finished) {
                }];*/
                
                //update time line with new composition
                [self.mediaTimeLineView updateTimeLineWith:self.slideShowComposition];
            }
            //update duration setting icon
            [self updateDurationSettingIcon];
            //update the scroll + content view for time line
            [self.timeLinePanelContentView setFrame:CGRectMake(0, 0, self.timeLinePanelView.frame.size.width + self.mediaTimeLineView.frame.size.width, self.timeLinePanelView.frame.size.height)];
            [self.timeLinePanelView setContentSize:self.timeLinePanelContentView.frame.size];
            self.mediaTimeLineView.center = CGPointMake(self.timeLinePanelContentView.frame.size.width/2, self.timeLinePanelContentView.frame.size.height/2);
            
            //update preview progress width
            [self.slideShowPreView setRealProgressWidth:self.mediaTimeLineView.frame.size.width];
            //return a block callback
            completionBlock();
            //animation
        });
    });
}


- (SCBasicBuilderComposition*)createBuilderComposition
{
    if(self.slideShowComposition.transitions.count > 0 )
    {
        SCAdvancedMediaBuilder *builder = [[SCAdvancedMediaBuilder alloc] initWithSlideShow:self.slideShowComposition];
        self.builderComposition = [builder buildMediaComposition];
        //builder = nil;
    }
    else
    {
        SCBasicMediaBuilder *builder = [[SCBasicMediaBuilder alloc] initWithSlideShow:self.slideShowComposition];
        self.builderComposition = [builder buildMediaComposition];
        //builder = nil;
    }
    return self.builderComposition;
}

- (SCSlideComposition*)currentSelectedSlide
{
    // get current slide composition at thic time
    int index = (int)(self.timeLinePanelView.contentOffset.x / SC_SLIDE_ITEM_SIZE.width) ;
    
    if( index >= 0 &&  index < self.slideShowComposition.slides.count)
    {
        return [self.slideShowComposition.slides objectAtIndex:index];
    }
    
    return nil;
}

- (void)gotoProgressPosition:(float)position
{
    [self.timeLinePanelView setContentOffset:CGPointMake(position , self.timeLinePanelView.contentOffset.y) animated:NO];
    
    float progress = self.timeLinePanelView.contentOffset.x / self.mediaTimeLineView.frame.size.width;
    if(self.timeLinePanelView.contentOffset.x >= self.timeLinePanelView.contentSize.width - self.timeLinePanelView.frame.size.width)
        progress = 1;
    if(self.timeLinePanelView.contentOffset.x <= 0)
        progress = 0;
    
    [self.slideShowPreView seekingTo:progress];
    [self clearTextLayerView];
}

- (void)playPreview
{
    if(self.slideShowPreView)
    {
        //clear all text
        [self clearTextLayerView];
        [self.playBtn setSelected:YES];
        [self.slideShowPreView play];
        if(self.progressTimer.isValid)
        {
            [self.progressTimer invalidate];
            self.progressTimer = nil;
        }
        
        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.018 target:self selector:@selector(updateScrollView:) userInfo:nil repeats:YES];
    }
}

- (void)pausePreview
{
    if(self.slideShowPreView)
    {
        [self.playBtn setSelected:NO];
        [self.slideShowPreView pause];
        if(self.progressTimer.isValid)
        {
            [self.progressTimer invalidate];
            self.progressTimer = nil;
        }
    }
}

- (void)updateScrollView:(id)sender
{
    if(self.playBtn.isSelected)
    {
        [self.timeLinePanelView setContentOffset:CGPointMake([self.slideShowPreView currentViewProgress] * self.mediaTimeLineView.frame.size.width, self.timeLinePanelView.contentOffset.y) animated:NO];
    }
    [self clearTextLayerView];
}

- (void)updateTextLayer
{
    //get current slie composition to update text layer
    SCSlideComposition *slide = [self.mediaTimeLineView getCurrentSlideWithPosition:self.timeLinePanelView.contentOffset];
    float currentProgress = self.slideShowPreView.currentPlayerTime;
    if(slide)
    {
        float start = CMTimeGetSeconds(slide.startTimeInTimeline);
        float end = CMTimeGetSeconds(slide.endTimeInTimeline);
        //NSLog(@"[%.2f][%.2f][%.2f]",start,currentProgress,end);
        if(start <= currentProgress && currentProgress <= end)
        {
            //NSLog(@"SHow Text layer");
        }
        else
        {
            [self clearTextLayerView];
        }
    }
}

- (void)setToolbarHidden:(BOOL)hide
{
    self.exportBtn.hidden = hide;
    self.playBtn.hidden = hide;
    self.addBtn.hidden = hide;
    self.filterBtn.hidden = hide;
}

- (void)showProgressHUDWithType:(MBProgressHUDMode)type andMessage:(NSString*)message
{
    //Prepare Progress HUD
    if(self.progressHUD.superview)
    {
        [self.progressHUD removeFromSuperview];
        self.progressHUD.delegate = nil;
        self.progressHUD = nil;
    }
    if(type == MBProgressHUDModeCustomView)
    {
        self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SC_PROGRESS_HUD_CHECKED]];
        [self.progressHUD show:YES];
        [self.progressHUD hide:YES afterDelay:0.5];
    }
    else
    {
        self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.progressHUD show:YES];
    }
    self.progressHUD.delegate = self;
    self.progressHUD.mode = type;
    self.progressHUD.labelText = message;
    self.progressHUD.progress = 0;
    [self.view addSubview:self.progressHUD];
}

- (void)hideProgressHUD
{
    //hide progress HUD
    [self.progressHUD show:NO];
    [self.progressHUD removeFromSuperview];
}

- (void)hideTopControl:(BOOL)hide
{
    self.backBtn.hidden = hide;
    self.durationSettingBtn.hidden = hide;
    self.helpBtn.hidden = hide;
}

- (void)updateDurationSettingIcon
{
    switch ([SCSlideShowSettingManager getInstance].videoDurationType)
    {
        case SCVideoDurationTypeVine:
            [self.durationSettingBtn setImage:[UIImage imageNamed:SC_IMG_VINE] forState:UIControlStateNormal];
            break;
        case SCVideoDurationTypeInstagram:
            [self.durationSettingBtn setImage:[UIImage imageNamed:SC_IMG_INSTAGRAM] forState:UIControlStateNormal];
            break;
        case SCVideoDurationTypeCustom:
            [self.durationSettingBtn setImage:[UIImage imageNamed:SC_IMG_CUSTOM] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)clearTextLayerView
{
    [self.currentSelectedSlideImgView setHidden:YES];
}

- (void)updatePreview
{
    self.slideShowPreView.alpha = 1;
    [UIView animateWithDuration:0.2 animations:^{
        self.slideShowPreView.alpha = 0;
    } completion:^(BOOL finished) {
        [self sliderUpdate:nil];
        [UIView animateWithDuration:0.2 animations:^{
            self.slideShowPreView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }];
}

#pragma mark - slideshow protocol

- (void)finishCropAllPhoto
{
    //get data from project detail
    [self resetEditorWithSlideShowCompositionWithSuccess:^
     {
         if(self.needToUpdateDurationSetting)
         {
             [[SCSlideShowSettingManager getInstance] updateNumberPhoto:self.slideShowComposition.slides.count
                                                       andTotalDuration:self.mediaTimeLineView.realDuration];
             self.needToUpdateDurationSetting = NO;
             [self updateDurationSettingIcon];
         }
     }];
}

#pragma mark - media time line Protocol

- (void)startEditAudioRecordTrack
{
    if(!self.recordView)
    {
        self.recordView = [[SCAudioRecordView alloc]init];
        [self.recordView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.recordView.delegate = self;
    }
    
    if(!self.recordView.superview)
    {
        //pause preview
        [self pausePreview];

        //set cusor to the begin of audiorecord view
        self.currentTimeBeforeRecording =  ((CMTimeGetSeconds(self.slideShowComposition.totalDuration) * [self.mediaTimeLineView getCurrentAudioRecordBegin]))
        / self.mediaTimeLineView.frame.size.width;
        [self gotoProgressPosition:[self.mediaTimeLineView getCurrentAudioRecordBegin]];
        [self.view addSubview:self.recordView];
        //start editing record audio
        if(self.slideShowComposition.audios.count > 0)
        {
            SCAudioComposition *audioRecord = [self.slideShowComposition.audios objectAtIndex:0];
            [self.recordView startEditingAudioWith:audioRecord playBack:YES];
        }
        else
            [self.recordView startEditingAudioWith:nil playBack:NO];

        [self.recordView zoomInWithCompletion:^
         {
             [self hideTopControl:YES];

         }];
    }
}

- (void)startEditMusicTrack
{
    if(!self.soundTrackView)
    {
        self.soundTrackView = [[SCSoundTrackView alloc]init];
        [self.soundTrackView setFrame:CGRectMake(0, self.toolBarPanelView.frame.origin.y, self.soundTrackView.frame.size.width,self.soundTrackView.frame.size.height)];
        self.soundTrackView.delegate = self;
    }
    
    if(!self.soundTrackView.superview)
    {
        //pause preview
        [self pausePreview];
        [self.view addSubview:self.soundTrackView];
        if(self.slideShowComposition.musics.count  > 0)
        {
            SCAudioComposition *music = [self.slideShowComposition.musics objectAtIndex:0];
            [self.soundTrackView updateWithMusicComposition:music];
        }
        [self.soundTrackView moveUpWithCompletion:^
         {
             [self hideTopControl:YES];

         }];
    }
}

- (void)audioRecordReachToEndingTimeLine
{
    [self pausePreview];
    //go to the position before recording
    [self.timeLinePanelView setContentOffset:CGPointMake((self.currentTimeBeforeRecording * self.mediaTimeLineView.frame.size.width) / CMTimeGetSeconds(self.slideShowComposition.totalDuration) , self.timeLinePanelView.contentOffset.y) animated:NO];
    [self.recordView stopRecording];
}

- (void)didSelectPhotoItemAtPos:(CGPoint)pos andSlide:(SCSlideComposition *)slide
{
    if(!self.playBtn.isSelected)
    {
        [self gotoProgressPosition:pos.x];
        //enable text editor + enable filter
        self.filterBtn.enabled = YES;
        
        //incase we are using filter feature
        if(self.imageFilterView.superview)
        {
            [self.imageFilterView updateWith:slide];
        }
        else
        {
            if(slide)
            {
                /*[self.currentSelectedSlideImgView setHidden:NO];
                UIImage *image = slide.filterComposition.filteredImage ? slide.filterComposition.filteredImage : slide.image;
                [self.currentSelectedSlideImgView setImage:image];
                [self.textEditorView beginEditingWithSlideComposition:slide keyBoardAppear:NO];*/
            }
        }
    }
}

- (void)startSorting
{
    [self pausePreview];
}

- (void)didFinishSortingSlideShow
{
    //update time-line with asynchronous
    [self updateTimeLineDataWithSuccess:^
     {
         //update current progress
     }];
}

- (void)didFinishDeletePhotoItemInSlideShow
{
    //update time-line with asynchronous
    [self updateTimeLineDataWithSuccess:^
     {
         //update current progress
         [[SCSlideShowSettingManager getInstance] updateNumberPhoto:self.slideShowComposition.slides.count andTotalDuration:self.mediaTimeLineView.realDuration];
         [self updateDurationSettingIcon];
     }];
}

- (void)didFinishDeleteMediaItemInSlideShow
{
    if(self.slideShowComposition.musics.count == 0)
    {
        [self.soundTrackView deleteSong];
    }
    
    if(self.slideShowComposition.audios.count == 0)
    {
        [self.recordView deleteAudio];
    }
    //update time-line with asynchronous
    [self updateTimeLineDataWithSuccess:^
     {
         //update current progress
     }];
}


#pragma mark - Slide show preview Protocol

- (void)currentProgessFromPlayer:(float)progress
{
    
}

- (void)playerStatus:(SCMediaStatus)status
{
   
}

- (void)playerReachEndPoint
{
    [self pausePreview];
}

#pragma mark - Soundtrack Protocol

- (void)didCancelSelectSong
{
    [self hideTopControl:NO];
}

- (void)didFinishEditingMusic:(SCAudioComposition *)musicComposition
{
    if(musicComposition && self.slideShowComposition)
    {
        if(self.slideShowComposition.musics.count > 0)
        {
            [self.slideShowComposition.musics removeAllObjects];
        }
        [self.slideShowComposition.musics addObject:musicComposition];
    }
    else if(!musicComposition)
    {
        if(self.slideShowComposition.musics.count > 0)
        {
            [self.slideShowComposition.musics removeAllObjects];
        }
    }
    
    //update time-line with asynchronous
    [self updateTimeLineDataWithSuccess:^
     {
         //update current progress
         [self hideTopControl:NO];
     }];
}

#pragma mark - audio record protocol

- (void)startRecording
{
    [self.slideShowPreView setBasicData:self.builderComposition];
    
    NSLog(@"Current player time [%f]",self.slideShowPreView.currentPlayerTime);

    self.currentTimeBeforeRecording =  ((CMTimeGetSeconds(self.slideShowComposition.totalDuration) * self.timeLinePanelView.contentOffset.x) )
    / self.mediaTimeLineView.frame.size.width;

    float lastPosition = (self.currentTimeBeforeRecording * self.mediaTimeLineView.frame.size.width) / CMTimeGetSeconds(self.slideShowComposition.totalDuration);
    NSLog(@"Last cursor position %2.f", lastPosition);
    [self gotoProgressPosition:lastPosition];
 
    [self.recordView setStartTimeForRecording:self.currentTimeBeforeRecording];
    [self.mediaTimeLineView createAudioRecordAt:self.currentTimeBeforeRecording];
    
}

- (void)stopRecording
{
    [self pausePreview];
    float lastPosition = (self.currentTimeBeforeRecording * self.mediaTimeLineView.frame.size.width) / CMTimeGetSeconds(self.slideShowComposition.totalDuration);
    NSLog(@"Last cursor position %2.f", lastPosition);
    [self gotoProgressPosition:lastPosition];
    NSLog(@"Current player time [%f]",self.slideShowPreView.currentViewProgress);
}

- (void)pauseRecord
{
    //pause the time line
}

- (void)recordingWithDuration:(float)time
{
    if(!self.slideShowPreView.isPlaying)
        [self playPreview];

    if(self.recordView && self.mediaTimeLineView)
    {
        [self.mediaTimeLineView updateAudioRecordViewWith:time];
    }
}

- (void)reTake
{
    //[self pausePreview];
    //scroll to update last cursor position
    /*float lastPosition = (self.currentTimeBeforeRecording * self.mediaTimeLineView.frame.size.width) / CMTimeGetSeconds(self.slideShowComposition.totalDuration);
    NSLog(@"Last cursor position %2.f", lastPosition);
    [self gotoProgressPosition:lastPosition];*/
}

- (void)didFinishRecordingWith:(SCAudioComposition *)audioComposition
{
    [self pausePreview];

    if(audioComposition && self.slideShowComposition)
    {
        if(self.slideShowComposition.audios.count > 0)
        {
            [self.slideShowComposition.audios removeAllObjects];
        }
        [self.slideShowComposition.audios addObject:audioComposition];
        
    }
    else if(!audioComposition)
    {
        if(self.slideShowComposition.audios.count > 0)
        {
            [self.slideShowComposition.audios removeAllObjects];
        }
        //remove audio line view in media time line
        [self.mediaTimeLineView deleteAudioRecord];
    }
    
    //update time-line with asynchronous
    [self updateTimeLineDataWithSuccess:^
     {
         //scroll to update last cursor position
         float lastPosition = (self.currentTimeBeforeRecording * self.mediaTimeLineView.frame.size.width) / CMTimeGetSeconds(self.slideShowComposition.totalDuration);
         NSLog(@"Last cursor position %2.f", lastPosition);
         [self gotoProgressPosition:lastPosition];
         
         [self hideTopControl:NO];
         self.currentSubView = nil;
     }];
}

- (void)recordPlayBack
{
    
}

#pragma mark - Text Editor protocol

- (void)startToEditText
{
    [self onAddTextBtn:nil];
}

- (void)didEndEditting
{
    [self clearTextLayerView];
}

- (void)didFinishEditingText:(SCSlideComposition *)slideComposition
{
    // re update time line with new text layout in the selected slider
    if(self.slideShowComposition && slideComposition.needToUpdate && slideComposition)
    {
        [self.slideShowComposition updateAsynchronouslyWithCompletionHandler:^
         {
             [self hideProgressHUD];
             if(!self.slideShowPreView && !self.mediaTimeLineView)
             {
                 //init preview panel
                 [self initPreViewPanel];
                 //init time line panel
                 [self initTimeLinePanel];
             }
             else
             {
                 //update preview with new music composition
                 [self.slideShowPreView setBasicData:[self createBuilderComposition]];
                 
                 //update time line with new music time line
                 [self.mediaTimeLineView updateTimeLineWith:self.slideShowComposition];
                 
                 //update progress
                 float progress = self.timeLinePanelView.contentOffset.x / self.mediaTimeLineView.frame.size.width;
                 if(self.timeLinePanelView.contentOffset.x >= self.timeLinePanelView.contentSize.width - self.timeLinePanelView.frame.size.width)
                     progress = 1;
                 if(self.timeLinePanelView.contentOffset.x <= 0)
                     progress = 0;
                 [self.slideShowPreView seekingTo:progress];
             }
         }];
    }
    self.currentSubView = nil;

}

- (void)didPasteTextObjectFromClipboard
{
    SCSlideComposition *slide = [self.mediaTimeLineView getCurrentSlideWithPosition:self.timeLinePanelView.contentOffset];
    if(slide)
    {
        if(self.currentSelectedSlideImgView.isHidden)
        {
            [self.currentSelectedSlideImgView setHidden:NO];
            UIImage *image = slide.filterComposition.filteredImage ? slide.filterComposition.filteredImage : slide.image;
            [self.currentSelectedSlideImgView setImage:image];
        }
    }
}

#pragma mark - duration setting delegate

- (void)didFinishSetting:(BOOL)hasChanged
{
    //update all compositon and all video item from slide show
    if(hasChanged)
    {
        [SCFileManager deleteAllfileFromTempWithExtension:SC_MOV];
        //get data from project detail
        [self showProgressHUDWithType:MBProgressHUDModeIndeterminate andMessage:NSLocalizedString(@"processing", nil)];
        [self resetEditorWithSlideShowCompositionWithSuccess:^
         {
             [self gotoProgressPosition:0];
         }];
    }
    self.currentSubView = nil;
}

#pragma mark - filter potocol

- (void)didSelectedFilterOnSlideComposition:(SCSlideComposition *)slideComposition
{
    if(self.imageFilterView.superview)
    {
        SCPhotoStripItemView *itemView = [self.mediaTimeLineView getSLideItemViewWith:slideComposition];
        if(itemView)
            [itemView refreshPhoto];
        
        [self.slideShowComposition updateAsynchronouslyWithCompletionHandler:^
         {
             [self hideProgressHUD];
             if(!self.slideShowPreView && !self.mediaTimeLineView)
             {
                 //init preview panel
                 [self initPreViewPanel];
                 //init time line panel
                 [self initTimeLinePanel];
             }
             else
             {
                 //update preview with new music composition
                 [self.slideShowPreView setBasicData:[self createBuilderComposition]];
                 //update time line with new music time line
                 [self.mediaTimeLineView updateTimeLineWith:self.slideShowComposition];
             }
             [self sliderUpdate:nil];

         }];

    }
}

- (void)didFinishSettingFilterWithChanged:(BOOL)changed
{
    //update all slide which were changed after filter
    if(changed)
    {
        if(self.imageFilterView)
        {
            [self.imageFilterView hidePreviewfilterImageWith:^
             {
                 [self clearTextLayerView];
             }];
        }
    }
    [self setToolbarHidden:NO];
    [self hideTopControl:NO];
    self.currentSubView = nil;
}

#pragma mark  - photo picker protocol

- (void)closeCropViewWithOnePhoto:(SCSlideComposition *)slideComposition {
    if(slideComposition)
    {
        // get current index
        int index = [self.slideShowComposition.slides indexOfObject:[self.mediaTimeLineView getCurrentSlideWithPosition:self.timeLinePanelView.contentOffset]];
        float startTrans = [SCSlideShowSettingManager getInstance].transitionDuration;
        float duration = [SCSlideShowSettingManager getInstance].slideDuration;
        float endTrans = [SCSlideShowSettingManager getInstance].transitionDuration;
        
        if(index == 0)
            startTrans = 0;
        else
            startTrans = [SCSlideShowSettingManager getInstance].transitionDuration;
        
        if(index == self.slideShowComposition.slides.count - 1)
            endTrans = 0;
        else
            endTrans = [SCSlideShowSettingManager getInstance].transitionDuration;
        
        [slideComposition updateSlide:duration startTrans:startTrans endTrans:endTrans transType:[SCSlideShowSettingManager getInstance].transitionType];
        
        //insert into slide composition with choice between first or last
        SCPhotoStripItemView *itemView = [self.mediaTimeLineView getCurrentSlideItemViewWithPosition:self.timeLinePanelView.contentOffset];
        if(itemView.center.x < self.timeLinePanelView.contentOffset.x)
            index = index + 1;
        [self.slideShowComposition addSlideComposition:slideComposition atIndex:index];
        
        [self updateTimeLineDataWithSuccess:^
         {
             //animation with the new slide photoview
             SCPhotoStripItemView *itemView = [self.mediaTimeLineView getSLideItemViewWith:slideComposition];
             if(itemView)
             {
                 [itemView zoomInWithCompletion:^{
                     
                 }];
             }
             //update current position
             //update setting manager
             [[SCSlideShowSettingManager getInstance] updateNumberPhoto:self.slideShowComposition.slides.count andTotalDuration:self.mediaTimeLineView.realDuration];
             [self updateDurationSettingIcon];
         }];
    }
    self.currentSubView = nil;

}


#pragma mark - scrollview delegate - control the slideshow timeline to adjust progress

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //NSLog(@"Begin dragging");
    if(!self.sliderTimer.isValid )
    {
        self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:DELTA_TIME target:self selector:@selector(sliderUpdate:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.sliderTimer forMode:NSRunLoopCommonModes];
        //pause the player
        self.lastPlaying = [self.slideShowPreView isPlaying];
        [self.slideShowPreView pause];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"End dragging");
    if(!self.timeLinePanelView.isDecelerating && !self.timeLinePanelView.isDragging)
    {
        if(self.sliderTimer.isValid)
        {
            [self.sliderTimer invalidate];
            self.sliderTimer = nil;
            [self.slideShowPreView endSeekingTo:0];
            if(self.lastPlaying)
            {
               [self playPreview];
                self.lastPlaying = NO;
            }
            else
            {
                [self pausePreview];
            }
            //check to update filter photos
            if(self.imageFilterView.superview)
            {
                //enable text editor + enable filter
                SCSlideComposition *slide = [self.mediaTimeLineView getCurrentSlideWithPosition:self.timeLinePanelView.contentOffset];
                //incase we are using filter feature
                if(self.imageFilterView.superview)
                {
                    [self.imageFilterView updateWith:slide];
                    [self.currentSelectedSlideImgView setHidden:YES];
                }
            }
        }
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"Ending Decelerating");
    if(self.sliderTimer.isValid)
    {
        [self.sliderTimer invalidate];
        self.sliderTimer = nil;
        //[self.slideShowPreView endSeekingTo:0];
        if(self.lastPlaying)
        {
            [self playPreview];
            self.lastPlaying = NO;
        }        //check to update filter photos
        else
        {
            [self pausePreview];
        }
        if(self.imageFilterView.superview)
        {
            //enable text editor + enable filter
            SCSlideComposition *slide = [self.mediaTimeLineView getCurrentSlideWithPosition:self.timeLinePanelView.contentOffset];
            //incase we are using filter feature
            if(self.imageFilterView.superview)
            {
                [self.imageFilterView updateWith:slide];
            }
        }

    }
}


- (void)sliderUpdate:(id)sender
{
    float progress = self.timeLinePanelView.contentOffset.x / self.mediaTimeLineView.frame.size.width;
    if(self.timeLinePanelView.contentOffset.x >= self.timeLinePanelView.contentSize.width - self.timeLinePanelView.frame.size.width)
        progress = 1;
    if(self.timeLinePanelView.contentOffset.x <= 0)
        progress = 0;
    
    [self.slideShowPreView seekingTo:progress];
    if(!self.imageFilterView.superview)
        [self clearTextLayerView];
}

- (float)currentTimeLineProgress
{
    return self.timeLinePanelView.contentOffset.x;
}


#pragma mark - delegate export progress

- (void)percentOfExportProgress:(float)percent
{
    
}

- (void)didFinishExportVideoWithSuccess:(BOOL)status
{
    
    
}


#pragma mark - delegate prebuild slideshow progress

- (void)prebuildProgressValue:(float)currentValue totalValue:(float)totalValue
{
    //update preview progress value
    //NSLog(@"Preview progress %.2f percent", currentValue*100/totalValue );
    if(self.progressHUD)
    {
        self.progressHUD.progress = ((float)currentValue / (float)totalValue);
    }
}


#pragma mark - clear

- (void)clearAll
{
    [super clearAll];
    //clear timer
    if(self.sliderTimer.isValid)
    {
        [self.sliderTimer invalidate];
        self.sliderTimer = nil;
    }
    
    if(self.progressTimer.isValid)
    {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    
    //clear time line
    [self.mediaTimeLineView clearAll];
    if(self.mediaTimeLineView.superview)
        [self.mediaTimeLineView removeFromSuperview];
    self.mediaTimeLineView = nil;
    
    //clear slideshow preview
    [self.slideShowPreView clearAll];
    if(self.slideShowPreView.superview)
        [self.slideShowPreView removeFromSuperview];
    self.slideShowPreView = nil;
    
    //clear sound track
    [self.soundTrackView clearAll];
    if(self.soundTrackView.superview)
        [self.soundTrackView removeFromSuperview];
    self.soundTrackView = nil;
   
    //clear audio record
    [self.recordView clearAll];
    if(self.recordView.superview)
        [self.recordView removeFromSuperview];
    self.recordView = nil;
    
    //clear setting duration
    [self.durationSettingView clearAll];
    if(self.durationSettingView.superview)
        [self.durationSettingView removeFromSuperview];
    self.durationSettingView = nil;
    
    //clear filter
   if(self.imageFilterView.superview)
   {
       [self.imageFilterView removeFromSuperview];
   }
    [self.imageFilterView clearAll];
    self.imageFilterView = nil;
    
    //clear slide composition
    //[self.slideShowComposition clearAll];
    self.slideShowComposition = nil;
    
    //clear bulider composition
    self.builderComposition = nil;
    
    // clear HUD
    if(self.progressHUD.superview)
    {
        [self.progressHUD removeFromSuperview];
    }
    self.progressHUD = nil;
}

@end


