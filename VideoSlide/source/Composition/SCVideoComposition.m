//
//  SCVideoComposition.m
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCVideoComposition.h"

#define THUMBNAIL_COUNT 4
#define THUMBNAIL_SIZE CGSizeMake(227.0f, 128.0f)


@interface SCVideoComposition ()

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) NSMutableArray *images;


@end

@implementation SCVideoComposition

@synthesize model = _model;
@synthesize thumbnails = _thumbnails;
@synthesize startTransition = _startTransition;
@synthesize endTransition = _endTransition;
@synthesize playthroughTimeRange = _playthroughTimeRange;
@synthesize startTimeInTimeline = _startTimeInTimeline;
@synthesize endTransitionTimeRange = _endTransitionTimeRange;


+ (id)videoItemWithURL:(NSURL *)url
{
	return [[self alloc] initWithURL:url];
}

- (id)initWithURL:(NSURL *)url
{
	self = [super initWithURL:url];
	if (self) {
		self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
		self.imageGenerator.maximumSize = THUMBNAIL_SIZE;
		self.thumbnails = @[];
		self.images = [NSMutableArray arrayWithCapacity:THUMBNAIL_COUNT];
	}
	return self;
}

- (id)initWithModel:(SCVideoModel *)model
{
    self = [super initWithModel:model];
    if(self)
    {
        if([model isKindOfClass:[SCVideoModel class]])
        {
            self.model = (SCVideoModel*)model;
        }
    }
    
    return self;
}

#pragma mark - save/load process

- (void)updateModel
{
    
}

- (void)getInfoFromModel
{
    
}


- (void)clearModel
{

}


#pragma mark - get/set
// Always pass back valid time range.  If no start or end transition playthroughTimeRange equals the media item timeRange.
- (CMTimeRange)playthroughTimeRange {
	CMTimeRange range = self.timeRange;
	if (self.startTransition && self.startTransition.type != SCVideoTransitionTypeNone) {
		range.start = CMTimeAdd(range.start, self.startTransition.duration);
		range.duration = CMTimeSubtract(range.duration, self.startTransitionTimeRange.duration);
	}
	if (self.endTransition && self.endTransition.type != SCVideoTransitionTypeNone) {
		range.duration = CMTimeSubtract(range.duration, self.endTransition.duration);
	}
	return range;
}

- (CMTimeRange)startTransitionTimeRange {
	if (self.startTransition && self.startTransition.type != SCVideoTransitionTypeNone) {
		return CMTimeRangeMake(kCMTimeZero, self.startTransition.duration);
	}
	return CMTimeRangeMake(kCMTimeZero, kCMTimeZero);
}

- (CMTimeRange)endTransitionTimeRange {
	if (self.endTransition && self.endTransition.type != SCVideoTransitionTypeNone) {
		CMTime beginTransitionTime = CMTimeSubtract(self.timeRange.duration, self.endTransition.duration);
		return CMTimeRangeMake(beginTransitionTime, self.endTransition.duration);
	}
	return CMTimeRangeMake(self.timeRange.duration, kCMTimeZero);
}

- (NSString *)mediaType {
	// This is actually muxed, but treat as video for our purposes
	return AVMediaTypeVideo;
}

#pragma mark - class util methods

- (void)performPostPrepareActionsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self generateThumbnailsWithCompletionBlock:completionBlock];
	});
}

- (void)generateThumbnailsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
    
	CMTime duration = self.asset.duration;
	CMTimeValue intervalSeconds = duration.value / THUMBNAIL_COUNT;
    
	CMTime time = kCMTimeZero;
	NSMutableArray *times = [NSMutableArray array];
	for (NSUInteger i = 0; i < THUMBNAIL_COUNT; i++) {
		[times addObject:[NSValue valueWithCMTime:time]];
		time = CMTimeAdd(time, CMTimeMake(intervalSeconds, duration.timescale));
	}
    
	[self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:^(CMTime requestedTime,
                                                                  CGImageRef cgImage,
                                                                  CMTime actualTime,
                                                                  AVAssetImageGeneratorResult result,
                                                                  NSError *error)
    {
        
		if (cgImage)
        {
			UIImage *image = [UIImage imageWithCGImage:cgImage];
			[self.images addObject:image];
            
		}
        else
        {
			[self.images addObject:[UIImage imageNamed:@"video_thumbnail"]];
		}
        
		if (self.images.count == THUMBNAIL_COUNT)
        {
			dispatch_async(dispatch_get_main_queue(), ^
            {
				self.thumbnails = [NSArray arrayWithArray:self.images];
				completionBlock(YES);
			});
		}
	}];
}

#pragma mark - clear data

- (void)clearAll
{
    [super clearAll];
    self.model = nil;
    self.thumbnails = nil;
    self.startTransition =nil;
    self.endTransition = nil;
    
}

@end
