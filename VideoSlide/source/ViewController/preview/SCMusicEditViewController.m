//
//  SCMusicEditViewController.m
//  VideoSlide
//
//  Created by Thi Huynh on 3/10/14.
//  Copyright (c) 2014 Doremon. All rights reserved.
//

#import "SCMusicEditViewController.h"
#import "SCHelper.h"

@interface SCMusicEditViewController ()  <UIScrollViewDelegate, AVAudioPlayerDelegate,MPMediaPickerControllerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *musicBtn;
@property (nonatomic, strong) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) IBOutlet UIButton *backBtn;
@property (nonatomic, strong) IBOutlet UILabel  *songNameLb;
@property (nonatomic, strong) IBOutlet UILabel  *timeLb;
@property (nonatomic, strong) IBOutlet UILabel  *artistLb;

@property (nonatomic, strong) IBOutlet UIScrollView      *musicScrollView;
@property (nonatomic, strong) IBOutlet UIImageView       *musicContentView;
@property (nonatomic, strong) UIView                     *musicProgressView;


@property (nonatomic, strong) SCSlideShowComposition *slideShowComposition;

@property (nonatomic, strong)  MPMediaPickerController *picker;
@property (nonatomic, strong)	AVAudioPlayer			*musicPlayer;
@property (nonatomic, strong)	NSURL					*selectedSongURL;
@property (nonatomic)           BOOL                    lastPlaying;
@property (nonatomic)           BOOL                    isDraging;
@property (nonatomic)           float                   startPlaytime;
@property (nonatomic)           float                   endPlaytime;
@property (nonatomic)           float                   musicTotalDuraion;

@property (nonatomic, strong)   NSTimer                   *sliderTimer;
@property (nonatomic, strong)   NSTimer                   *playTimer;
@property (nonatomic, strong)   SCAudioComposition        *musicComposition;
@property (nonatomic, strong)   UITapGestureRecognizer    *musicTapGesture;




- (IBAction)onNextBtn:(id)sender;
- (IBAction)onBackBtn:(id)sender;
- (IBAction)onMusicBtn:(id)sender;
@end

@implementation SCMusicEditViewController

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
    self.slideShowComposition = [self.lastData objectForKey:SC_TRANSIT_KEY_SLIDE_SHOW_DATA];
    
    //init song picker
    self.picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    self.picker.delegate						= self;
    self.picker.allowsPickingMultipleItems	= YES;
    self.picker.prompt						= NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
    [self.picker setAllowsPickingMultipleItems:NO];
    
    //hide all info item
    [self.musicScrollView setHidden:YES];
    [self.songNameLb setHidden:YES];
    [self.timeLb setHidden:YES];
    [self.artistLb setHidden:YES];

    
    self.musicTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMusicTap:)];
    self.musicTapGesture.numberOfTapsRequired = 1;
    [self.musicScrollView addGestureRecognizer:self.musicTapGesture];
    
    self.musicProgressView = [[UIView alloc] initWithFrame:self.musicScrollView.frame];
    [self.musicProgressView setBackgroundColor:[UIColor whiteColor]];
    self.musicProgressView.alpha = 0.3;
    [self.view addSubview:self.musicProgressView];
    self.musicProgressView.hidden  = YES;
    [self.musicProgressView setUserInteractionEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)clearAll
{
    [super clearAll];
    if(self.sliderTimer.isValid)
    {
        [self.sliderTimer invalidate];
        self.sliderTimer = nil;
    }
    
    if(self.playTimer.isValid)
    {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
    
    if(self.musicPlayer)
    {
        [self.musicPlayer stop];
        self.musicPlayer = nil;
    }
}

#pragma mark - actions

- (void)onNextBtn:(id)sender
{
    
    if(self.musicComposition)
    {
        self.musicComposition.timeRange = CMTimeRangeMake(CMTimeMake([self currentTime] * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS), self.slideShowComposition.totalDuration);
        self.musicComposition.duration = self.musicComposition.timeRange.duration;
        
        //set fadein/out
        self.musicComposition.volume = 1;
        
        if(self.slideShowComposition.musics.count > 0)
        {
            [self.slideShowComposition.musics removeAllObjects];
        }
        [self.slideShowComposition.musics addObject:self.musicComposition];
    
    }
    else
    {
        if(self.slideShowComposition.musics.count > 0)
        {
            [self.slideShowComposition.musics removeAllObjects];
        }
    }

    if(self.slideShowComposition.slides.count > 0)
    {
        if(self.sliderTimer.isValid)
        {
            [self.sliderTimer invalidate];
            self.sliderTimer = nil;
        }
        
        if(self.playTimer.isValid)
        {
            [self.playTimer invalidate];
            self.playTimer = nil;
        }
        
        if(self.musicPlayer.isPlaying)
        {
            [self.musicPlayer pause];
        }
        [self gotoScreen:SCEnumPreviewScreen data:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.slideShowComposition, SC_TRANSIT_KEY_SLIDE_SHOW_DATA ,nil]];
    }

}

- (void)onBackBtn:(id)sender
{
    [self goBack];
}

- (void)onMusicBtn:(id)sender
{
    if(self.musicPlayer.isPlaying)
    {
        [self.musicPlayer pause];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self presentViewController:self.picker animated:YES completion:^
     {
         [self.picker setNeedsStatusBarAppearanceUpdate];

     }];
}

- (void)onMusicTap:(UIGestureRecognizer*)gestureRecognize
{
    if(self.playTimer.isValid)
    {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
    if(self.sliderTimer.isValid)
    {
        [self.sliderTimer invalidate];
        self.sliderTimer = nil;
    }

    [self.musicPlayer setCurrentTime:[self currentTime]];
    if(self.musicPlayer && !self.musicScrollView.isDecelerating)
    {
        if(!self.musicPlayer.isPlaying)
        {
            [self.musicPlayer play];
            self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.018 target:self selector:@selector(onPlay:) userInfo:nil repeats:YES];
            self.musicProgressView.hidden = NO;
            self.musicProgressView.frame = CGRectMake(0, 0, 0, self.musicScrollView.frame.size.height);
        }
        else
        {
            [self.musicPlayer pause];
            self.timeLb.text = [NSString stringWithFormat:@"Start time : %@",[SCHelper mediaTimeFormatFrom:[self currentTime]]];
            self.musicProgressView.hidden = YES;

        }
        
    }
    
}

- (void)onPlay:(id)sender
{
    //if(self.musicPlayer.currentTime - [self currentTime] < CMTimeGetSeconds( self.slideShowComposition.totalDuration))
    {
        self.timeLb.text = [NSString stringWithFormat:@"%@ - %@",[SCHelper mediaTimeFormatFrom:[self currentTime]],[SCHelper mediaTimeFormatFrom:self.musicPlayer.currentTime]];
        self.musicProgressView.frame = CGRectMake(0,
                                                  self.musicScrollView.frame.origin.y,
                                                  (self.musicPlayer.currentTime - [self currentTime]) * self.musicScrollView.frame.size.width / CMTimeGetSeconds( self.slideShowComposition.totalDuration),
                                                  self.musicScrollView.frame.size.height);

    }
   /* else
    {
        [self.musicPlayer pause];
        self.musicProgressView.hidden = YES;
        [self.musicPlayer setCurrentTime:[self currentTime]];
        self.timeLb.text = [NSString stringWithFormat:@"Start time : %@",[SCHelper mediaTimeFormatFrom:[self currentTime]]];
        [self.playTimer invalidate];
    }*/

}

#pragma mark Media item picker delegate methods
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
	[self dismissViewControllerAnimated:YES completion:nil];
    if(!self.musicComposition)
    {
       
    }
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
	// Dismiss the media item picker.
	[self dismissViewControllerAnimated:YES completion:nil];
    
    MPMediaItem *item=[[mediaItemCollection items] objectAtIndex:0];
    self.selectedSongURL = [item valueForProperty: MPMediaItemPropertyAssetURL];
    NSLog(@"ID = [%@]",[item valueForProperty:MPMediaItemPropertyPersistentID]);
    NSLog(@"Title = [%@]",[item valueForProperty:MPMediaItemPropertyTitle]);
    NSLog(@"URL = [%@]",[item valueForProperty:MPMediaItemPropertyAssetURL]);
    
    if(![item valueForProperty:MPMediaItemPropertyAssetURL])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"song_unvailable", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if(self.musicPlayer)
    {
        [self.musicPlayer stop];
        self.musicPlayer  = nil;
    }
    
    self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.selectedSongURL error: nil];
	[self.musicPlayer prepareToPlay];
	[self.musicPlayer setDelegate:self];
    
    //update song into editor
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString *mediaID = ((NSNumber*)[item valueForProperty:MPMediaItemPropertyPersistentID]).stringValue;
    NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
    self.musicTotalDuraion = self.musicPlayer.duration;
    //create music composition
    [self.musicComposition clearAll];
    self.musicComposition = nil;
    if(!self.musicComposition)
    {
        self.musicComposition = [[SCAudioComposition alloc]initWithURL:self.selectedSongURL fadeInTime:SC_AUDIO_FADE_DEFAULT_DURATION fadeOutTime:SC_AUDIO_FADE_DEFAULT_DURATION];
        self.musicComposition.name = title;
        self.musicComposition.mediaID = mediaID;
        
        [self showProgressHUDWithType:MBProgressHUDModeIndeterminate andMessage:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^
        {
            NSData *waveData = [SCAudioUtil renderPNGAudioPictogramLogForAssett:[AVURLAsset URLAssetWithURL:self.selectedSongURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}]];
            UIImage *waveImg = [UIImage imageWithData:waveData];
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self hideProgressHUD];
                float musicWidth = self.musicScrollView.frame.size.width * self.musicPlayer.duration / CMTimeGetSeconds(self.slideShowComposition.totalDuration);
                self.musicContentView.frame = CGRectMake(0, 0,musicWidth, self.musicContentView.frame.size.height);
                [self.musicScrollView setContentSize:self.musicContentView.frame.size];
                [self.musicContentView setImage:waveImg];
                
                self.musicScrollView.hidden = NO;
                self.timeLb.hidden = NO;
                self.songNameLb.hidden = NO;
                self.artistLb.hidden = NO;


                self.musicScrollView.alpha = 0;
                self.timeLb.alpha  = 0;
                self.songNameLb.alpha = 0;
                self.artistLb.alpha = 0;
                
                self.songNameLb.text = self.musicComposition.title;
                self.timeLb.text = [NSString stringWithFormat:@"Start time : %@",[SCHelper mediaTimeFormatFrom:[self currentTime]]];
                self.artistLb.text = artist;

                [UIView animateWithDuration:0.3 animations:^{
                    [self.musicBtn setCenter:CGPointMake(self.musicBtn.center.x,450)];
                    [self.musicBtn setTransform:CGAffineTransformMakeScale(0.7, 0.7)];
                    self.musicScrollView.alpha = 1;
                    self.timeLb.alpha  = 1;
                    self.songNameLb.alpha = 1;
                    self.artistLb.alpha = 1;

                } completion:^(BOOL finished) {

                }];
                
            });
            
        });
        
    }
}


#pragma mark - scrollview delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.musicPlayer.isPlaying)
    {
        [self.musicPlayer pause];
        if(self.playTimer.isValid)
        {
            [self.playTimer invalidate];
            self.playTimer = nil;
        }
        self.musicProgressView.hidden = YES;
    }
    self.timeLb.text = [NSString stringWithFormat:@"Start time : %@",[SCHelper mediaTimeFormatFrom:[self currentTime]]];
    if(self.sliderTimer.isValid)
    {
        [self.sliderTimer invalidate];
        self.sliderTimer = nil;
    }
    self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:DELTA_TIME target:self selector:@selector(sliderUpdate:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.sliderTimer forMode:NSRunLoopCommonModes];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.timeLb.text = [NSString stringWithFormat:@"Start time : %@",[SCHelper mediaTimeFormatFrom:[self currentTime]]];
    if(!scrollView.isDecelerating)
    {
        if(self.sliderTimer.isValid)
        {
            [self.sliderTimer invalidate];
            self.sliderTimer = nil;
        }
        [self.musicPlayer setCurrentTime:((scrollView.contentOffset.x * self.musicPlayer.duration) / scrollView.contentSize.width)];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.timeLb.text = [NSString stringWithFormat:@"Start time : %@",[SCHelper mediaTimeFormatFrom:[self currentTime]]];
    if(self.sliderTimer.isValid)
    {
        [self.sliderTimer invalidate];
        self.sliderTimer = nil;
    }
    [self.musicPlayer setCurrentTime:((scrollView.contentOffset.x * self.musicPlayer.duration) / scrollView.contentSize.width)];
}

- (void)sliderUpdate:(NSTimer*)timer
{
    self.timeLb.text = [NSString stringWithFormat:@"Start time : %@",[SCHelper mediaTimeFormatFrom:[self currentTime]]];
}

#pragma mark - methods

- (float)currentTime
{
    float result = 0;
    if(self.musicPlayer)
    {
        result = (self.musicScrollView.contentOffset.x * self.musicPlayer.duration) / self.musicScrollView.contentSize.width;
    }
    
    return result;
}




@end
