//
//  SCMediaComposition.m
//  SlideshowCreator
//
//  Created 9/25/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCMediaComposition.h"

static NSString *const AVAssetTracksKey = @"tracks";
static NSString *const AVAssetDurationKey = @"duration";
static NSString *const AVAssetCommonMetadataKey = @"commonMetadata";

@interface SCMediaComposition ()
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *filename;
@end

@implementation SCMediaComposition

@synthesize url  =_url;
@synthesize title  =_title;
@synthesize mediaType =_mediaType;
@synthesize asset = _asset;
@synthesize prepared = _prepared;
@synthesize mediaID = _mediaID;

- (id)initWithURL:(NSURL *)url {
	self = [super init];
	if (self) {
		_url = url;
		_filename = [[url lastPathComponent] copy];
		_asset = [AVURLAsset URLAssetWithURL:url options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
        self.startTimeInTimeline =  kCMTimeZero;
        self.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
        self.duration = self.asset.duration;
	}
	return self;
}

- (NSString *)title {
	if (!_title) {
		for (AVMetadataItem *metaItem in [self.asset commonMetadata]) {
			if ([metaItem.commonKey isEqualToString:AVMetadataCommonKeyTitle]) {
				_title = [metaItem stringValue];
				break;
			}
		}
	}
	if (!_title) {
		_title = self.filename;
	}
	return _title;
}

- (NSString *)mediaType {
	NSAssert(NO, @"Must be overridden in subclass.");
	return nil;
}

- (void)prepareWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
	[self.asset loadValuesAsynchronouslyForKeys:@[AVAssetTracksKey, AVAssetDurationKey, AVAssetCommonMetadataKey] completionHandler:^{
		// Production code should be more robust.  Specifically, should capture error in failure case.
		AVKeyValueStatus tracksStatus = [self.asset statusOfValueForKey:AVAssetTracksKey error:nil];
		AVKeyValueStatus durationStatus = [self.asset statusOfValueForKey:AVAssetDurationKey error:nil];
		_prepared = (tracksStatus == AVKeyValueStatusLoaded) && (durationStatus == AVKeyValueStatusLoaded);
		if (self.prepared) {
			self.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
			[self performPostPrepareActionsWithCompletionBlock:completionBlock];
		} else {
			completionBlock(NO);
		}
	}];
}

- (void)performPostPrepareActionsWithCompletionBlock:(THPreparationCompletionBlock)completionBlock {
	if (completionBlock) {
		completionBlock(self.prepared);
	}
}

- (BOOL)isTrimmed {
	if (!self.prepared) {
		return NO;
	}
	return CMTIME_COMPARE_INLINE(self.timeRange.duration, <, self.asset.duration);
}

- (AVPlayerItem *)makePlayable {
	return [AVPlayerItem playerItemWithAsset:self.asset];
}

- (BOOL)isEqual:(id)other {
	if (self == other) {
		return YES;
	}
	if (!other || ![other isKindOfClass:[self class]]) {
		return NO;
	}
    
	return [self.url isEqual:[other url]];
}

- (NSUInteger)hash {
	return [self.url hash];
}


- (void)resetTimeRangeWithAsset
{
    self.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
}

#pragma mark - instance methods

- (void)deleteAssetFile
{
    if(self.url)
    {
        [SCFileManager deleteFileWithURL:self.url];
    }

}

#pragma mark - model

- (id)initWithModel:(SCCompositionModel *)model
{
    self = [super initWithModel:model];
    {
        if(model.projectURL)
        {
            self.projectURL = [NSURL fileURLWithPath:model.projectURL];
            self.title = model.name;
        }
    }
    
    return self;
}
- (void)updateModel
{
    
}

- (void)getInfoFromModel
{
    
}

#pragma mark - clear data

- (void)clearAll
{
    [super clearAll];
    self.asset = nil;
}


@end
