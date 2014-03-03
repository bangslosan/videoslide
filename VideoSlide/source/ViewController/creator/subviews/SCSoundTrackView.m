//
//  SCSoundTrackView.m
//  SlideshowCreator
//
//  Created 10/14/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSoundTrackView.h"

#define SC_MAX_TRIM_LENGTH  280
#define SC_BTN_TRIM_WIDTH   13


@interface SCSoundTrackView () <UIScrollViewDelegate, AVAudioPlayerDelegate,MPMediaPickerControllerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *selectSongBtn;
@property (nonatomic, strong) IBOutlet UIButton *deleteBtn;
@property (nonatomic, strong) IBOutlet UIButton *acceptBtn;

@property (nonatomic, strong) IBOutlet UIScrollView *timeLineScrollView;
@property (nonatomic, strong) IBOutlet UIView   *scrollContentView;
@property (nonatomic, strong) IBOutlet UIView   *audioTimeLineView;
@property (nonatomic, strong) IBOutlet UIImageView   *audioWaveImgView;
@property (nonatomic, strong) IBOutlet UIImageView   *audioIncreaseIconImgView;
@property (nonatomic, strong) IBOutlet UIImageView   *audioDecreaseIconImgView;


@property (nonatomic, strong) IBOutlet UIView   *trimedView;
@property (nonatomic, strong) IBOutlet UIButton *cursorBtn;

@property (nonatomic, strong) IBOutlet UILabel *startTimeLb;
@property (nonatomic, strong) IBOutlet UILabel *fullTimeLb;
@property (nonatomic, strong) IBOutlet UILabel *trimResultTimeLb;


@property (nonatomic, strong) IBOutlet UIButton *firstTrimBtn;
@property (nonatomic, strong) IBOutlet UIButton *secondTrimBtn;

@property (nonatomic, strong) IBOutlet UIView *firstTrimTimeView;
@property (nonatomic, strong) IBOutlet UIView *secondTrimTimeView;
@property (nonatomic, strong) IBOutlet UILabel *firstTrimTimeLb;
@property (nonatomic, strong) IBOutlet UILabel *secondTrimTimeLb;

@property (nonatomic, strong) IBOutlet UISlider *volumeSlider;
@property (nonatomic, strong) IBOutlet UIButton *playBtn;
@property (nonatomic, strong) IBOutlet UIButton *fadeInBtn;
@property (nonatomic, strong) IBOutlet UIButton *fadeOutBtn;

@property (nonatomic, strong)  MPMediaPickerController *picker;
@property (nonatomic, strong)	AVAudioPlayer			*musicPlayer;
@property (nonatomic, strong)	NSURL					*selectedSongURL;
@property (nonatomic)           BOOL                    lastPlaying;
@property (nonatomic)           BOOL                    isDraging;
@property (nonatomic)           float                   startPlaytime;
@property (nonatomic)           float                   endPlaytime;
@property (nonatomic)           float                   musicTotalDuraion;
@property (nonatomic, strong)   NSMutableArray          *imgWaveViews;




@property (nonatomic, strong)   NSTimer                   *sliderTimer;
@property (nonatomic, strong)   NSTimer                   *autoScrollTimer;
@property (nonatomic, strong)   NSTimer                   *playTimer;
@property (nonatomic, strong)   SCAudioComposition        *musicComposition;

@property (nonatomic, strong)   UIPanGestureRecognizer   *panGesture;
@property (nonatomic, strong)   UITapGestureRecognizer   *trimViewtapGesture;



- (void)setEditToolHidden:(BOOL)value;
- (void)updateTimelineWith:(float)startTime duration:(float)duration title:(NSString*)title;
- (void)updateTrimSectionLabel;
- (void)updateTrimedView;

- (void)playMusic;
- (void)stopMusic;
- (void)autoScrollTimeLineWithGesture;
- (void)setWaveViewShow:(BOOL)value;


- (IBAction)onSelectSongBtn:(id)sender;
- (IBAction)onDeleteBtn:(id)sender;
- (IBAction)onAcceptBtn:(id)sender;
- (IBAction)onFadeInBtn:(id)sender;
- (IBAction)onFadeOutBtn:(id)sender;
- (IBAction)onPlayBtn:(id)sender;
- (IBAction)onVolumeChange:(id)sender;


@end


@implementation SCSoundTrackView

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
    self = [[[NSBundle mainBundle] loadNibNamed:@"SCSoundTrackView" owner:self options:nil] objectAtIndex:0];
    if(self)
    {
        self.lastPlaying = NO;
        self.isDraging = NO;
        self.musicTotalDuraion = 0;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //hide all edit tool
    [self setEditToolHidden:YES];

    //create custom thumb for slider
    UIImage *thumbImage = [UIImage imageNamed:SC_BTN_IMG_VOLUME_THUMB];
    [self.volumeSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.volumeSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];

    //create tuch = drag for 2  buton
    //first button
    [self.firstTrimBtn addTarget:self action:@selector(wasDragged:withEvent:)
     forControlEvents:UIControlEventTouchDragInside];
    
	// adself.firstTrimBtnd tap listener
	[self.firstTrimBtn addTarget:self action:@selector(wasTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    
    // add it, centered
    [self.firstTrimBtn addTarget:self action:@selector(dragBegan:withEvent:) forControlEvents: UIControlEventTouchDown];
    [self.firstTrimBtn addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents: UIControlEventTouchDragInside];
    [self.firstTrimBtn addTarget:self action:@selector(dragEnded:withEvent:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    //second button
    [self.secondTrimBtn addTarget:self action:@selector(wasDragged:withEvent:)
                forControlEvents:UIControlEventTouchDragInside];
    
	// adself.firstTrimBtnd chtap listener
	[self.secondTrimBtn addTarget:self action:@selector(wasTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    
    // add it, centered
    [self.secondTrimBtn addTarget:self action:@selector(dragBegan:withEvent:) forControlEvents: UIControlEventTouchDown];
    [self.secondTrimBtn addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents: UIControlEventTouchDragInside];
    [self.secondTrimBtn addTarget:self action:@selector(dragEnded:withEvent:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

    // there is no song at this time
    [self updateTimelineWith:0 duration:0 title:SC_MESSAGE_SELECT_SONG];
    
    //add gesture for the trimed  audio track view
    //self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    //[self.trimedView addGestureRecognizer:self.panGesture];

    //add gesture for the trimed  audio track view
    //self.trimViewtapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    //[self.trimedView addGestureRecognizer:self.trimViewtapGesture];
    [self.trimedView setUserInteractionEnabled:NO];
    
    //init song picker
    self.picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    self.picker.delegate						= self;
    self.picker.allowsPickingMultipleItems	= YES;
    self.picker.prompt						= NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
    [self.picker setAllowsPickingMultipleItems:NO];
    
    self.imgWaveViews = [[NSMutableArray alloc] init];
}


#pragma mark - get/set methods

- (void)setMusicComposition:(SCAudioComposition *)music
{
    _musicComposition = music;
}

- (void)updateWithMusicComposition:(SCAudioComposition *)music
{
    if(self.musicComposition)
    {
        [self updateTimelineWith:0 duration:self.musicTotalDuraion title:self.musicComposition.name];
        //update time line
        return;
    }
    
    self.musicComposition = music;
    [self.volumeSlider setValue:self.musicComposition.volume];
    if(self.musicComposition.mediaID && music)
    {
        [self setEditToolHidden:NO];
        
        //get song from itunes that is available
        MPMediaQuery *everything = [[MPMediaQuery alloc] init];
        NSArray *itemsFromGenericQuery = [everything items];
        for(MPMediaItem *mediaItem in itemsFromGenericQuery)
        {
            NSString *songID = ((NSNumber*)[mediaItem valueForProperty: MPMediaItemPropertyPersistentID]).stringValue;
            if([self.musicComposition.mediaID isEqualToString:songID])
            {
                self.musicComposition.url = [mediaItem valueForProperty: MPMediaItemPropertyAssetURL];
                self.selectedSongURL = self.musicComposition.url;
            }
        }
        if(self.selectedSongURL)
        {
            if(self.musicPlayer)
            {
                [self.musicPlayer stop];
                self.musicPlayer  = nil;
            }
            self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.selectedSongURL error: nil];
            self.musicTotalDuraion = self.musicPlayer.duration;
            NSString *title = self.musicComposition.title;
            // "Preparing to play" attaches to the audio hardware and ensures that playback
            //		starts quickly when the user taps Play
            [self.musicPlayer prepareToPlay];
            [self.musicPlayer setVolume: self.volumeSlider.value];
            [self.musicPlayer setDelegate:self];
            
            //update song into editor
            [self updateTimelineWith:0 duration:self.musicTotalDuraion title:title];
            
            //show all edit tool
            [self setEditToolHidden:NO];
            [self updateTrimSectionLabel];
            
            //update fadein/out button
            [self.fadeInBtn setSelected:self.musicComposition.fadeIn.enable];
            [self.fadeOutBtn setSelected:self.musicComposition.fadeOut.enable];
        }
        //if song was delete from itunes --> notice and remove the reference
        else
        {
            [self.musicComposition clearAll];
            self.musicComposition = nil;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"%@ is no long available. Please choose another song" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (void)setEditToolHidden:(BOOL)value
{
    self.firstTrimTimeView.hidden = YES;
    self.secondTrimTimeView.hidden = YES;
    
    self.firstTrimBtn.hidden = value;
    self.secondTrimBtn.hidden = value;
    
    self.playBtn.hidden = value;
    self.deleteBtn.hidden = value;
    
    self.fadeInBtn.hidden = value;
    self.fadeOutBtn.hidden = value;
    self.volumeSlider.hidden = value;
    
    self.audioDecreaseIconImgView.hidden = value;
    self.audioIncreaseIconImgView.hidden = value;
    
    //self.cursorBtn.hidden = value;
    self.trimedView.hidden = value;
    
    //self.audioWaveImgView.hidden = value;
    [self setWaveViewShow:!value];

}

- (void)deleteSong
{
    //stop + release player
    if(self.musicPlayer.isPlaying)
    {
        [self.musicPlayer stop];
        [self.playBtn setSelected:NO];
        self.musicPlayer = nil;
    }
    self.musicPlayer = nil;
    //empty music compostion
    self.selectedSongURL = nil;
    if(self.musicComposition)
    {
        [self.musicComposition clearAll];
        self.musicComposition = nil;
    }
    //update UI
    [self updateTimelineWith:0 duration:0 title:SC_MESSAGE_SELECT_SONG];
    
    //hide all edit tool
    [self setEditToolHidden:YES];

}


- (void)showItunes
{
    [self onSelectSongBtn:self.selectSongBtn];
    [self setHidden:YES];
}

- (void)setWaveViewShow:(BOOL)value
{
    if(value)
    {
        if( self.audioTimeLineView.subviews.count > 0)
        {
            for(UIImageView *imgView in self.audioTimeLineView.subviews)
            {
                [imgView removeFromSuperview];
            }
        }
        for(int i = 0 ;i <= self.audioTimeLineView.frame.size.width / self.audioWaveImgView.frame.size.width; i++)
        {
            if(i == 0)
               [self.audioTimeLineView addSubview:self.audioWaveImgView];
            else
            {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i*self.audioWaveImgView.frame.size.width,self.audioWaveImgView.frame.origin.y, self.audioWaveImgView.frame.size.width, self.audioWaveImgView.frame.size.height)];
                [imgView setImage:self.audioWaveImgView.image];
                [self.audioTimeLineView addSubview:imgView];
            }
        }
        
    }
    else
    {
        if( self.audioTimeLineView.subviews.count > 0)
        {
            for(UIImageView *imgView in self.audioTimeLineView.subviews)
            {
                [imgView removeFromSuperview];
            }
        }
    }
}

#pragma mark - actions

- (IBAction)onSelectSongBtn:(id)sender
{
    // The media item picker uses the default UI style, so it needs a default-style
    //		status bar to match it visually
    //[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
    //stop + release player
    if(self.musicPlayer.isPlaying)
    {
        [self.musicPlayer stop];
        [self.playBtn setSelected:NO];
    }
    [[SCScreenManager getInstance].rootViewController presentViewController:self.picker animated:YES completion:nil];
        
}

- (IBAction)onDeleteBtn:(id)sender
{
    [self deleteSong];
}

- (IBAction)onAcceptBtn:(id)sender
{
    if(self.superview)
    {
        [self stopMusic];
        if([self.delegate respondsToSelector:@selector(didFinishEditingMusic:)])
        {
            if(self.musicComposition)
            {
                float firstTrimTime = (self.timeLineScrollView.contentOffset.x  + self.firstTrimBtn.center.x - SC_BTN_TRIM_WIDTH / 2) * self.musicPlayer.duration/ self.audioTimeLineView.frame.size.width ;
                float secondTrimTime = (self.timeLineScrollView.contentOffset.x + self.secondTrimBtn.center.x + SC_BTN_TRIM_WIDTH /2 ) * self.musicPlayer.duration/ self.audioTimeLineView.frame.size.width ;
                if(firstTrimTime < 0)
                    firstTrimTime =0;
                if(secondTrimTime < 0)
                    secondTrimTime = 0;
                
                float trimDuration = secondTrimTime - firstTrimTime;
                if(trimDuration > 0)
                {
                    NSLog(@"[Sound track trim result time: [%.2f]",trimDuration);
                    self.musicComposition.timeRange = CMTimeRangeMake(CMTimeMake(firstTrimTime * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS), CMTimeMake(trimDuration * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS));
                    self.musicComposition.duration = self.musicComposition.timeRange.duration;
                    
                    //set fadein/out
                    self.musicComposition.fadeIn.enable = self.fadeInBtn.isSelected;
                    self.musicComposition.fadeOut.enable = self.fadeOutBtn.isSelected;
                    //set volume
                    self.musicComposition.volume = self.volumeSlider.value;
                    
                    [self.delegate didFinishEditingMusic:self.musicComposition];
                    
                    //exit sound track
                    [self moveDownWithCompletion:^
                     {
                         [self removeFromSuperview];
                     }];
                }
                else
                {
                    NSLog(@"invalid trim section");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Can not trim music . Please try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
            else
            {
                [self.delegate didFinishEditingMusic:self.musicComposition];
                //exit sound track
                [self moveDownWithCompletion:^
                 {
                     
                     [self removeFromSuperview];
                 }];
            }
        }
    }
}

- (IBAction)onFadeInBtn:(id)sender
{
    [self.fadeInBtn setSelected:!self.fadeInBtn.isSelected];
}

- (IBAction)onFadeOutBtn:(id)sender
{
    [self.fadeOutBtn setSelected:!self.fadeOutBtn.isSelected];
}

- (IBAction)onPlayBtn:(id)sender
{
    if(self.timeLineScrollView.isDecelerating)
        return;
    if(self.musicPlayer)
    {
        [((UIButton*)sender) setSelected:!((UIButton*)sender).isSelected];
        if(((UIButton*)sender).isSelected)
        {
            [self playMusic];
        }
        else
        {
            [self pauseMusic];
        }
    }
}


- (IBAction)onVolumeChange:(id)sender
{
    if(self.musicPlayer)
    {
        [self.musicPlayer setVolume:self.volumeSlider.value];
        self.musicComposition.volume = self.volumeSlider.value;
    }
}

#pragma mark - trim button drag and drop

- (void)dragBegan:(UIControl *)c withEvent:ev
{
    self.isDraging = NO;
}

- (void)dragMoving:(UIControl *)c withEvent:ev
{
    self.isDraging = YES;
}

- (void)dragEnded:(UIControl *)c withEvent:ev
{
    self.isDraging = NO;
}

- (void)wasTapped:(UIButton *)button
{
    if (self.isDraging == NO)
    {
    
    }
}

- (void)wasDragged:(UIButton *)button withEvent:(UIEvent *)event
{
    //stop the music player
    [self stopMusic];
    // get the touch
	UITouch *touch = [[event touchesForView:button] anyObject];
	// get delta
	CGPoint previousLocation = [touch previousLocationInView:button];
	CGPoint location = [touch locationInView:button];
	CGFloat delta_x = location.x - previousLocation.x;
    
	// move button
    if(button.center.x + delta_x - SC_BTN_TRIM_WIDTH/2 >= 0 &&
       button.center.x + delta_x + SC_BTN_TRIM_WIDTH/2 <= self.timeLineScrollView.frame.size.width)
    {
        button.center = CGPointMake(button.center.x + delta_x,button.center.y );
        //check if out of range (range > 300)
        float maxRange = self.secondTrimBtn.center.x - self.firstTrimBtn.center.x  + SC_BTN_TRIM_WIDTH;
        if(maxRange > SC_MAX_TRIM_LENGTH)
            button.center = CGPointMake(button.center.x - delta_x,button.center.y );
    }
    if(button == self.firstTrimBtn)
    {
        if(self.firstTrimBtn.center.x + SC_BTN_TRIM_WIDTH/2 > self.secondTrimBtn.frame.origin.x )
        {
            self.firstTrimBtn.center = CGPointMake(self.secondTrimBtn.frame.origin.x - self.firstTrimBtn.frame.size.width / 2, self.firstTrimBtn.center.y);
        }
    }
    else
    {
        if(self.firstTrimBtn.center.x + SC_BTN_TRIM_WIDTH/2 > self.secondTrimBtn.frame.origin.x )
        {
            self.secondTrimBtn.center = CGPointMake(self.firstTrimBtn.frame.origin.x + self.firstTrimBtn.frame.size.width + self.secondTrimBtn.frame.size.width /2  , self.secondTrimBtn.center.y);
        }
    }
    
    self.firstTrimTimeView.center = CGPointMake(self.firstTrimBtn.center.x, self.firstTrimTimeView.center.y);
    self.secondTrimTimeView.center = CGPointMake(self.secondTrimBtn.center.x, self.secondTrimTimeView.center.y);
    
    [self updateTrimSectionLabel];
    [self updateTrimedView];
}


#pragma mark Media item picker delegate methods
// Invoked when the user taps the Done button in the media item picker having chosen zero
//		media items to play
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
	[[SCScreenManager getInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
    if(!self.musicComposition)
    {
        if([self.delegate respondsToSelector:@selector(didCancelSelectSong)])
        {
            [self.delegate didCancelSelectSong];
        }
        [self moveDownWithCompletion:^
         {
             [self setHidden:NO];
             [self removeFromSuperview];
         }];
    }
    else
        [self setHidden:NO];
}


// Invoked when the user taps the Done button in the media item picker after having chosen
//		one or more media items to play.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
	// Dismiss the media item picker.
	[[SCScreenManager getInstance].rootViewController dismissViewControllerAnimated:YES completion:nil];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated: YES];
    [self setHidden:NO];
    
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
	// "Preparing to play" attaches to the audio hardware and ensures that playback
	//		starts quickly when the user taps Play
	[self.musicPlayer prepareToPlay];
	[self.musicPlayer setVolume: self.volumeSlider.value];
	[self.musicPlayer setDelegate:self];

    //update song into editor
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    NSString *mediaID = ((NSNumber*)[item valueForProperty:MPMediaItemPropertyPersistentID]).stringValue;
    self.musicTotalDuraion = self.musicPlayer.duration;
    //create music composition
    [self.musicComposition clearAll];
    self.musicComposition = nil;
    if(!self.musicComposition)
    {
        self.musicComposition = [[SCAudioComposition alloc]initWithURL:self.selectedSongURL fadeInTime:SC_AUDIO_FADE_DEFAULT_DURATION fadeOutTime:SC_AUDIO_FADE_DEFAULT_DURATION];
        self.musicComposition.name = title;
        self.musicComposition.mediaID = mediaID;
    }
    [self.volumeSlider setValue:self.musicComposition.volume];
    
    [self updateTimelineWith:0 duration:self.musicTotalDuraion title:title];
    
    //show all edit tool
    [self setEditToolHidden:NO];
    [self updateTrimSectionLabel];
}


#pragma mark - class methods

- (void)updateTimelineWith:(float)startTime duration:(float)duration title:(NSString*)title
{
    [self.selectSongBtn setTitle:title forState:UIControlStateNormal];
    
    //update audio time line view with rule 180 second = 320px
    if(duration == 0)
    {
        [self.audioTimeLineView setFrame:CGRectMake(0,0, self.timeLineScrollView.frame.size.width , self.timeLineScrollView.frame.size.height)];
        [self.scrollContentView setFrame:CGRectMake(0,0, self.audioTimeLineView.frame.size.width , self.timeLineScrollView.frame.size.height)];
        [self.timeLineScrollView setContentSize:self.scrollContentView.frame.size];
    }
    else
    {
        float slideShowDuration = [SCSlideShowSettingManager getInstance].videoTotalDuration;
        float durationLengthInView = duration * SC_MAX_TRIM_LENGTH / slideShowDuration;
        [self.audioTimeLineView setFrame:CGRectMake(0,0, durationLengthInView, self.timeLineScrollView.frame.size.height)];
        [self.scrollContentView setFrame:CGRectMake(0, 0,self.audioTimeLineView.frame.size.width, self.timeLineScrollView.frame.size.height)];
        [self.timeLineScrollView setContentSize:self.scrollContentView.frame.size];
        
        //update trimview && start + end btn
        self.cursorBtn.hidden = YES;
        if(self.musicComposition &&  CMTimeGetSeconds(self.musicComposition.timeRange.duration) >0 && CMTimeGetSeconds(self.musicComposition.timeRange.duration) < self.musicPlayer.duration)
        {
            float trimedDurationInView = CMTimeGetSeconds(self.musicComposition.timeRange.duration) * SC_MAX_TRIM_LENGTH / slideShowDuration;
            float startDurationInview = CMTimeGetSeconds(self.musicComposition.timeRange.start) * SC_MAX_TRIM_LENGTH / slideShowDuration;
            float contentOffsetX = startDurationInview + trimedDurationInView/2 - self.timeLineScrollView.frame.size.width/2;
            if(contentOffsetX < 0)
                contentOffsetX = 0;
            [self.timeLineScrollView setContentOffset:CGPointMake(contentOffsetX, 0)];

            self.firstTrimBtn.center = CGPointMake(startDurationInview - self.timeLineScrollView.contentOffset.x + SC_BTN_TRIM_WIDTH/2 , self.firstTrimBtn.center.y);
            self.secondTrimBtn.center = CGPointMake(self.firstTrimBtn.center.x + trimedDurationInView - SC_BTN_TRIM_WIDTH , self.firstTrimBtn.center.y);

        }
        else
        {
            self.firstTrimBtn.center = CGPointMake(10 + SC_BTN_TRIM_WIDTH/2, self.firstTrimBtn.center.y);
            self.secondTrimBtn.center = CGPointMake(self.firstTrimBtn.center.x + SC_MAX_TRIM_LENGTH - SC_BTN_TRIM_WIDTH , self.firstTrimBtn.center.y);
            [self.timeLineScrollView setContentOffset:CGPointMake(0, 0)];

        }
        [self updateTrimedView];
    }
    [self updateTrimSectionLabel];

}

- (void)updateTrimSectionLabel
{
    float firstTrimTime = (self.timeLineScrollView.contentOffset.x  + self.firstTrimBtn.center.x - SC_BTN_TRIM_WIDTH / 2) * self.musicPlayer.duration/ self.audioTimeLineView.frame.size.width ;
    float secondTrimTime = (self.timeLineScrollView.contentOffset.x + self.secondTrimBtn.center.x + SC_BTN_TRIM_WIDTH /2 ) * self.musicPlayer.duration/ self.audioTimeLineView.frame.size.width ;
    
    self.firstTrimTimeLb.text = [SCHelper mediaTimeFormatFrom:firstTrimTime];
    self.secondTrimTimeLb.text = [SCHelper mediaTimeFormatFrom:secondTrimTime];
    
    //update time for trim
    self.trimResultTimeLb.text = [SCHelper mediaTimeFormatFrom:(secondTrimTime - firstTrimTime)];
    self.startTimeLb.text = [SCHelper mediaTimeFormatFrom:firstTrimTime];
    self.fullTimeLb.text = [SCHelper mediaTimeFormatFrom:secondTrimTime];

}

- (void)updateTrimedView
{
    float start = self.firstTrimBtn.center.x - SC_BTN_TRIM_WIDTH/2;
    float width = self.secondTrimBtn.center.x + SC_BTN_TRIM_WIDTH/2 - start;
    if(start + width > self.timeLineScrollView.frame.size.width)
        width = self.timeLineScrollView.frame.size.width - start;
    self.trimedView.frame = CGRectMake(start, self.trimedView.frame.origin.y, width, self.trimedView.frame.size.height);
}

- (void)playMusic
{
    [self.cursorBtn setHidden:NO];
    self.cursorBtn.centerX = 0;
    
    self.startPlaytime = (self.timeLineScrollView.contentOffset.x  + self.firstTrimBtn.center.x - SC_BTN_TRIM_WIDTH / 2) * self.musicPlayer.duration/ self.audioTimeLineView.frame.size.width;
    self.endPlaytime = (self.timeLineScrollView.contentOffset.x + self.secondTrimBtn.center.x + SC_BTN_TRIM_WIDTH /2 ) * self.musicPlayer.duration/ self.audioTimeLineView.frame.size.width ;

    [self.musicPlayer setCurrentTime:self.startPlaytime];
    [self.musicPlayer play];
    if(self.playTimer)
    {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.018 target:self selector:@selector(playTick:) userInfo:nil repeats:YES];

}

- (void)stopMusic
{
    [self.cursorBtn setHidden:YES];
    [self.playBtn setSelected:NO];
    [self.musicPlayer stop];
    if(self.playTimer.isValid)
    {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
}

- (void)pauseMusic
{
    [self.playBtn setSelected:NO];
    [self.musicPlayer pause];
    if(self.playTimer.isValid)
    {
        [self.playTimer invalidate];
        self.playTimer = nil;
    }
}

- (void)playTick:(NSTimer*)timer
{
    if(self.musicPlayer.isPlaying)
    {
        float deltaTime = self.musicPlayer.currentTime - self.startPlaytime;
        if(deltaTime < self.endPlaytime - self.startPlaytime)
        {
            float deltaWidth = deltaTime * self.audioTimeLineView.frame.size.width / self.musicPlayer.duration;
            self.cursorBtn.centerX = deltaWidth;
        }
        else
        {
            [self stopMusic];
        }
    }
    
}
#pragma mark - scrollview delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"Begin dragging");
    if(!self.sliderTimer.isValid )
    {
        self.sliderTimer = [NSTimer scheduledTimerWithTimeInterval:DELTA_TIME target:self selector:@selector(sliderUpdate:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.sliderTimer forMode:NSRunLoopCommonModes];
        [self stopMusic];
        [self updateTrimSectionLabel];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"End dragging");
    
    if(!self.timeLineScrollView.isDecelerating && !self.timeLineScrollView.isDragging)
    {
        if(self.sliderTimer.isValid)
        {
            [self.sliderTimer invalidate];
            self.sliderTimer = nil;
        }
        
        [self updateTrimSectionLabel];
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Ending Decelerating");
    if(self.sliderTimer.isValid)
    {
        [self.sliderTimer invalidate];
        self.sliderTimer = nil;
        
        //update music player
        if(self.lastPlaying && self.musicPlayer)
        {
            [self.musicPlayer play];
        }
        [self updateTrimSectionLabel];
    }
}


- (void)sliderUpdate:(id)sender
{
    [self updateTrimSectionLabel];
}

#pragma mark - audio player protocol
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopMusic];
}

#pragma mark - gesture

- (void)onTap:(UITapGestureRecognizer*)recognizer
{
    if(self.musicPlayer.isPlaying)
    {
        CGPoint localTranslation = [recognizer locationInView:recognizer.view];
        self.cursorBtn.centerX = localTranslation.x;
        float currentPosition  = self.timeLineScrollView.contentOffset.x + self.trimedView.frame.origin.x + localTranslation.x;
        float currentTime = currentPosition * self.musicPlayer.duration / self.audioTimeLineView.frame.size.width;
        [self.musicPlayer setCurrentTime:currentTime];
    }
}

- (void)onPan:(UIPanGestureRecognizer*)recognizer
{
    CGPoint translation = [recognizer locationInView:recognizer.view.superview];
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        //need to stop the player first
        [self stopMusic];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if(self.trimedView.frame.origin.x >= 0 && self.trimedView.frame.origin.x + self.trimedView.frame.size.width <= self.timeLineScrollView.frame.size.width)
        {
            self.trimedView.center = CGPointMake(translation.x,self.trimedView.center.y);
            if(self.trimedView.frame.origin.x <= 0)
            {
                self.trimedView.center = CGPointMake(self.trimedView.frame.size.width/2, self.trimedView.center.y);
                [self autoScrollTimeLineWithGesture];
            }
            else if(self.trimedView.frame.origin.x + self.trimedView.frame.size.width >= self.timeLineScrollView.frame.size.width)
            {
                self.trimedView.center = CGPointMake(self.timeLineScrollView.frame.size.width - self.trimedView.frame.size.width / 2,self.trimedView.center.y);
                [self autoScrollTimeLineWithGesture];
            }
            self.firstTrimBtn.center = CGPointMake(self.trimedView.frame.origin.x + SC_BTN_TRIM_WIDTH/2, self.firstTrimBtn.center.y);
            self.secondTrimBtn.center = CGPointMake(self.trimedView.frame.origin.x + self.trimedView.frame.size.width - SC_BTN_TRIM_WIDTH/2 , self.secondTrimBtn.center.y);
            
            self.firstTrimTimeView.center = CGPointMake(self.firstTrimBtn.center.x, self.firstTrimTimeView.center.y);
            self.secondTrimTimeView.center = CGPointMake(self.secondTrimBtn.center.x, self.secondTrimTimeView.center.y);
        }
        [self updateTrimSectionLabel];

    
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if(self.autoScrollTimer.isValid)
        {
            [self.autoScrollTimer invalidate];
            self.autoScrollTimer = nil;
        }
    }

}

- (void)autoScrollTimeLineWithGesture
{
    if(self.autoScrollTimer.isValid)
    {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
    
    self.autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.018 target:self selector:@selector(indicateTimeLineWithValue:) userInfo:nil repeats:YES];
}

- (void)indicateTimeLineWithValue:(id)sender
{
        float value = 0;
        if(self.trimedView.frame.origin.x <= 0)
            value = -3;
        else if(self.trimedView.frame.origin.x + self.trimedView.frame.size.width >= self.timeLineScrollView.frame.size.width)
            value = 3;
        [self.timeLineScrollView setContentOffset:CGPointMake(self.timeLineScrollView.contentOffset.x + value, self.timeLineScrollView.contentOffset.y) animated:NO];
        
        if(self.timeLineScrollView.contentOffset.x <= 0)
           [self.timeLineScrollView setContentOffset:CGPointMake(0, self.timeLineScrollView.contentOffset.y) animated:NO];
        else if(self.timeLineScrollView.contentOffset.x >= self.timeLineScrollView.contentSize.width - self.timeLineScrollView.frame.size.width)
            [self.timeLineScrollView setContentOffset:CGPointMake(self.timeLineScrollView.contentSize.width - self.timeLineScrollView.frame.size.width, self.timeLineScrollView.contentOffset.y) animated:NO];

        [self updateTrimSectionLabel];
}

#pragma mark - clear all

- (void)clearAll
{
    [super clearAll];
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
    
    if(self.autoScrollTimer.isValid)
    {
        [self.autoScrollTimer invalidate];
        self.autoScrollTimer = nil;
    }
    
    if(self.musicPlayer)
    {
        [self.musicPlayer stop];
        self.musicPlayer = nil;
    }
    
    if(self.picker)
    {
        [self.picker removeFromParentViewController];
        [self.picker dismissMoviePlayerViewControllerAnimated];
        self.picker = nil;
    }
    self.delegate = nil;
}



@end
