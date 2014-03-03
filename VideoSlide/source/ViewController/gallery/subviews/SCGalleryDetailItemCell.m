//
//  SCGalleryDetailItemCell.m
//  SlideshowCreator
//
//  Created 10/30/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCGalleryDetailItemCell.h"

@interface SCGalleryDetailItemCell()

@property (nonatomic, strong) IBOutlet UIButton *playBtn;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

- (IBAction)onPlay:(id)sender;
- (IBAction)onPause:(id)sender;


@end


@implementation SCGalleryDetailItemCell

@synthesize thumbnailImageView  =_thumbnailImageView;
@synthesize nameLb = _nameLb;
@synthesize timeLb = _timeLb;
@synthesize playURL = _playURL;
@synthesize delegate = _delegate;
@synthesize slideShow = _slideShow;

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

- (void)awakeFromNib
{
}

- (void)setDataWith:(SCSlideShowComposition*)slideShowData andImage:(UIImage*)img
{
    [self.thumbnailImageView setImage:img];
    self.nameLb.text = slideShowData.name;
    self.timeLb.text = [SCHelper mediaTimeFormatFrom:CMTimeGetSeconds(slideShowData.totalDuration)];
    self.numberPhoto.text = [NSString stringWithFormat:@"%d",slideShowData.slides.count];
    self.playURL =  [SCFileManager urlFromDir:slideShowData.exportURL withName:[slideShowData.name stringByAppendingPathExtension:SC_MOV]];

    
}
- (void)updateWithData:(SCSlideShowModel*)slideShow thumbnail:(UIImage*)thumbnail
{
    self.slideShow = slideShow;
    [self.thumbnailImageView setImage:thumbnail];
    self.nameLb.text = slideShow.name;
    self.timeLb.text = [SCHelper mediaTimeFormatFrom:slideShow.totalDuration];
    self.numberPhoto.text = [NSString stringWithFormat:@"%d",slideShow.slideArray.count];
    self.playURL =  [SCFileManager urlFromDir:[NSURL fileURLWithPath:slideShow.exportURL] withName:slideShow.exportVideoName];
}
- (IBAction)onPlay:(id)sender
{
    /*if([SCFileManager exist:self.playURL])
        [[SCScreenManager getInstance] playMovieWithUrl:self.playURL];*/
    [self playVideo];
    [self.playBtn setHidden:YES];

}
- (IBAction)onPause:(id)sender
{
    [self pauseVideo];
    [self.playBtn setHidden:NO];
}

#pragma mark - play/pause methods

- (void)playVideo
{
    if (!self.player)
    {
        self.player = [AVPlayer playerWithURL:self.playURL];
        self.playerLayer =[AVPlayerLayer playerLayerWithPlayer:self.player];
        CGRect rect = self.previewView.bounds;
        [self.playerLayer setFrame:rect];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.previewView.layer addSublayer:self.playerLayer];
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.player currentItem]];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:@"applicationWillResignActive" object:Nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:@"applicationDidBecomeActive" object:Nil];
    }
    [self.player play];
}

-(void)pauseVideo
{
    if(self.player)
    {
        [self.player pause];
    }
}

- (void)stopVideo
{
    if(self.player && self.playerLayer)
    {
        [self.player pause];
        self.player = nil;
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    [self.playBtn setHidden:NO];

}

#pragma mark - selector for observer

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    [self stopVideo];
}
- (void)applicationWillResignActive:(NSNotification *)ntf
{
    if(self.player)
    {
        [self.player pause];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)ntf
{
    if(self.player)
    {
        [self.player play];
    }
}


@end
