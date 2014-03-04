//
//  SCSlideComposition.m
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCSlideComposition.h"
#import "SCFileManager.h"
#import "SCTransitionComposition.h"

@implementation SCSlideComposition

@synthesize model  = _model;
@synthesize image = _image;
@synthesize imageWithText = _imageWithText;
@synthesize thumbnailImage = _thumbnailImage;
@synthesize assetURL = _assetURL;
@synthesize startTransition = _startTransition;
@synthesize endTransition = _endTransition;
@synthesize playthroughTimeRange = _playthroughTimeRange;
@synthesize startTimeInTimeline = _startTimeInTimeline;
@synthesize endTransitionTimeRange = _endTransitionTimeRange;
@synthesize originalImage = _originalImage;
@synthesize isCropped = _isCropped;
@synthesize texts = _texts;
@synthesize filterComposition = _filterComposition;
@synthesize needToRefreshThumbnail = _needToRefreshThumbnail;
@synthesize rectCropped = _rectCropped;
@synthesize currentScale = _currentScale;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.model = [[SCSlideModel alloc]init];
        self.image = nil;
        self.imageWithText = nil;
        self.texts               =  [[NSMutableArray alloc] init];
        self.filterComposition   = [[SCFilterComposition alloc] init];
        self.startTimeInTimeline =  kCMTimeZero;
        self.needToUpdate = YES;
        self.isCropped = NO;
        self.currentScale = 1;
        self.needToRefreshThumbnail = NO;
    }
    
    return self;
}

- (id)initWithImage:(UIImage*)img {
    self = [self init];
    if(self)
    {
        self.image               =  [[UIImage alloc] initWithCGImage:img.CGImage];
        self.thumbnailImage      =  [SCImageUtil imageWithImage:self.image scaledToSize:SC_THUMBNAIL_IMAGE_SIZE];
        self.originalImage       =  nil;
        self.imageWithText       =  nil;
        self.assetURL            =  nil;
        self.isCropped           =  NO;
        self.duration            =  CMTimeMake((0 + 0 + 0) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
        self.timeRange           =  CMTimeRangeMake(kCMTimeZero, self.duration);
    }
    
    return self;
}

- (id)initWithThumbnailImage:(UIImage*)thumbnailImage assetURL:(NSURL*)url {
    self = [self init];
    if(self)
    {
        self.image               =  nil;
        self.imageWithText       =  nil;
        self.thumbnailImage      =  thumbnailImage;
        self.originalImage       =  nil;
        self.assetURL            =  url;
        self.isCropped           =  NO;
        self.duration            =  CMTimeMake((0 + 0 + 0) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
        self.timeRange           =  CMTimeRangeMake(self.startTimeInTimeline, self.duration);
    }
    
    return self;
}

- (id)initWithImage:(UIImage*)img withThumbnail:(UIImage*)thumbnailImage {
    self = [self init];
    if(self)
    {
        self.image               =  img;
        self.imageWithText       =  nil;
        self.thumbnailImage      =  thumbnailImage;
        self.originalImage       =  nil;
        self.assetURL            =  nil;
        self.isCropped           =  NO;
        self.duration            =  CMTimeMake((0 + 0 + 0) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
        self.timeRange           =  CMTimeRangeMake(kCMTimeZero, self.duration);
    }
    
    return self;
}

- (id)initWithImage:(UIImage*)img withThumbnail:(UIImage*)thumbnailImage withOriginalImage:(UIImage*)originalImage {
    self = [self init];
    if(self)
    {
        self.image               =  img;
        self.imageWithText       =  nil;
        self.thumbnailImage      =  thumbnailImage;
        self.originalImage       =  originalImage;
        self.assetURL            =  nil;
        self.isCropped           =  NO;
        self.duration            =  CMTimeMake((0 + 0 + 0) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
        self.timeRange           =  CMTimeRangeMake(self.startTimeInTimeline, self.duration);
    }
    
    return self;
}

- (id)initWithImage:(UIImage*)img withThumbnail:(UIImage*)thumbnailImage assetURL:(NSURL*)url {
    self = [self init];
    if(self)
    {
        self.image               =  img;
        self.imageWithText       =  nil;
        self.thumbnailImage      =  thumbnailImage;
        self.originalImage       =  nil;
        self.assetURL            =  url;
        self.isCropped           =  NO;
        self.duration            =  CMTimeMake((0 + 0 + 0) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
        self.timeRange           =  CMTimeRangeMake(kCMTimeZero, self.duration);
    }
    
    return self;
}

// for duplicate photo
- (id)initWithImage:(UIImage*)img withThumbnail:(UIImage*)thumbnailImage withOriginalImage:(UIImage*)originalImage assetURL:(NSURL*)url {
    self = [self init];
    if(self)
    {
        self.image               =  img;
        self.imageWithText       =  nil;
        self.thumbnailImage      =  thumbnailImage;
        self.originalImage       =  originalImage;
        self.assetURL            =  url;
        self.isCropped           =  NO;
        self.duration            =  CMTimeMake((0 + 0 + 0) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
        self.timeRange           =  CMTimeRangeMake(kCMTimeZero, self.duration);
    }
    
    return self;
}

- (id)initWithImage:(UIImage*)img startTransTime:(float)startTrans endTransTime:(float)endTrans  duration:(float)duration;
{
    self = [self init];
    if(self)
    {
        self.image               =  img;
        self.imageWithText       =  nil;
        self.thumbnailImage      =  [SCImageUtil imageWithImage:self.image scaledToSize:SC_THUMBNAIL_IMAGE_SIZE];
        self.originalImage       =  nil;
        self.assetURL            =  nil;
        self.isCropped           =  NO;
        self.duration            =  CMTimeMake((startTrans + duration + endTrans) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
        self.timeRange           =  CMTimeRangeMake(kCMTimeZero, self.duration);
    }
    
    return self;
}


- (id)initWithModel:(SCCompositionModel *)model
{
    self = [super initWithModel:model];
    if(self)
    {
        if([model isKindOfClass:[SCSlideModel class]])
        {
            self.texts =  [[NSMutableArray alloc] init];
            self.model = (SCSlideModel*)model;
            [self getInfoFromModel];
        }
    }
    
    return self;
}


#pragma mark - save/load process

- (void)updateModel
{
    [self clearModel];
    
    self.model.name = self.name;
    self.model.duration = CMTimeGetSeconds(self.duration);
    self.model.startTime = CMTimeGetSeconds(self.startTimeInTimeline);
    self.model.projectURL      = self.projectURL.path;
    
    self.model.imgName = [self.name stringByAppendingPathExtension:SC_PNG];
    self.model.thumbnailImgName = [[self.name stringByAppendingString:@"-thumbnail"] stringByAppendingPathExtension:SC_PNG];
   
    self.imageURL = [SCFileManager urlFromDir:self.projectURL withName:self.model.imgName];
    self.thumbnailURL = [SCFileManager urlFromDir:self.projectURL withName:self.model.thumbnailImgName];

    //start transition
    if(self.startTransition)
    {
        [self.startTransition updateModel];
        self.model.startTrans = self.startTransition.model;
    }
    
    //end trasnsition
    if(self.endTransition)
    {
        [self.endTransition updateModel];
        self.model.endTrans = self.endTransition.model;
    }
    
    //text array
    if(self.texts.count > 0)
    {
        [self.model.textArray removeAllObjects];
        for(SCTextObjectView *textView in self.texts)
        {
            [textView.textComposition updateModel];
            [self.model.textArray addObject:textView.textComposition.model];
        }
    }
    
    //filter
    [self.filterComposition updateModel];
    self.model.filter = self.filterComposition.model;
    
    
}

- (void)getInfoFromModel
{
    if(self.model)
    {
        //images
        self.imageURL = [SCFileManager urlFromDir:self.projectURL withName:self.model.imgName];
        self.image = [[UIImage alloc] initWithContentsOfFile:self.imageURL.path];
        
        self.thumbnailURL = [SCFileManager urlFromDir:self.projectURL withName:self.model.thumbnailImgName];
        self.thumbnailImage = [self.image resizedImageWithMinimumSize:SC_THUMBNAIL_IMAGE_SIZE];//[[UIImage alloc] initWithContentsOfFile:self.thumbnailURL.path];
        
        //transitions
        self.startTransition = [[SCTransitionComposition alloc] initWithModel:self.model.startTrans];
        self.endTransition = [[SCTransitionComposition alloc] initWithModel:self.model.endTrans];

        //text array
        for(SCTextModel *text in self.model.textArray)
        {
            SCTextComposition *textComposition = [[SCTextComposition alloc] initWithModel:text];
            SCTextObjectView *textObj = [[SCTextObjectView alloc] initWithTextComposition:textComposition];
            [self.texts addObject:textObj];
        }
        
        //filter
        self.filterComposition = [[SCFilterComposition alloc] initWithModel:self.model.filter];
        if(self.filterComposition.filterMode != SCImageFilterModeNormal)
        {
            self.filterComposition.filteredImage = [SCImageUtil filterImage:self.image mode:self.filterComposition.filterMode];
            if(self.filterComposition.filteredImage)
                self.filterComposition.thumbnailFilteredImage = [SCImageUtil newImageWithImage:self.filterComposition.filteredImage scaledToSize:SC_THUMBNAIL_IMAGE_SIZE_RETINA];;
        }
    }
}


- (void)clearModel
{
    if(self.model)
    {
        [self.model clearAll];
        self.model = nil;
    }
    
    self.model = [[SCSlideModel alloc] init];
}

- (void)deleteAssetFile
{
    if(self.model)
    {
        NSURL *imageURL = [SCFileManager urlFromDir:self.projectURL withName:self.model.imgName];
        if([SCFileManager exist:imageURL])
        {
            [SCFileManager deleteFileWithURL:imageURL];
        }
        
        NSURL *thumbnailImg = [SCFileManager urlFromDir:self.projectURL withName:self.model.thumbnailImgName];
        if([SCFileManager exist:thumbnailImg])
        {
            [SCFileManager deleteFileWithURL:thumbnailImg];
        }
    
    }
}

#pragma mark - instance methods

- (void)cropImageWithRect:(CGRect)rect andScale:(float)scale
{
    if(rect.origin.x == rect.origin.y == rect.size.width ==0 || scale <= 0)
        return;
    
    if(self.image)
    {
        self.image = [SCImageUtil cropImageWith:self.image rect:rect];
        self.image = [SCImageUtil imageWithImage:self.image scaledToSize:CGSizeMake(self.image.size.width * scale, self.image.size.height * scale)];
        self.isCropped = YES;
    }
}

- (void)updateSlide:(float)duration startTrans:(float)startTrans endTrans:(float)endTrans transType:(SCVideoTransitionType)transType
{
    self.startTimeInTimeline =  kCMTimeZero;
    self.duration            =  CMTimeMake((startTrans + duration + endTrans) * SC_VIDEO_OUTPUT_FPS, SC_VIDEO_OUTPUT_FPS);
    self.timeRange           =  CMTimeRangeMake(kCMTimeZero, self.duration);
    self.startTransition     =  [[SCTransitionComposition alloc] initWithType:transType duration:startTrans];
    self.endTransition       =  [[SCTransitionComposition alloc] initWithType:transType duration:endTrans];

}

- (SCVideoComposition*)convertToVideoComposition:(BOOL)forExport
{
    if(self.image)
    {
        NSURL *outPut = [SCFileManager createURLFromTempWithName:[NSString stringWithFormat:@"%@.%@",self.name,SC_MOV]];
        [SCFileManager deleteFileWithURL:outPut];
        UIImage * neededImage;
        if(self.filterComposition.filterMode == SCImageFilterModeNormal)
        {
            neededImage = self.image;
        }
        else
        {
            neededImage = self.filterComposition.filteredImage;
        }
        //check to create video with text
        if(self.texts.count > 0)
        {
            //draw text to image here to write final video for composition
            CGSize previewSize;
            
            previewSize = SC_IS_IPHONE5 ? SC_PREVIEW_4INCH_SIZE:SC_PREVIEW_3INCH5_SIZE;
            self.imageWithText = [SCImageUtil imageTextWithSlideComposition:self previewSize:previewSize];
            [SCVideoUtil createStandardVideoWith:self.imageWithText size:SC_VIDEO_SIZE time:CMTimeGetSeconds(self.duration) output:outPut FPS:SC_VIDEO_BASIC_RENDER_FPS];
        }
        //create video item with output format
        else
        {
            [SCVideoUtil createStandardVideoWith:neededImage size:SC_VIDEO_SIZE time:CMTimeGetSeconds(self.duration) output:outPut FPS:SC_VIDEO_BASIC_RENDER_FPS];
        }

        SCVideoComposition *videoItem = [[SCVideoComposition alloc]initWithURL:outPut];
        if(CMTimeGetSeconds(videoItem.duration) > 0)
        {
            videoItem.startTimeInTimeline    = self.startTimeInTimeline;
            videoItem.timeRange              = self.timeRange;
            videoItem.startTransition        = self.startTransition;
            videoItem.endTransition          = self.endTransition;
            return  videoItem;
        }
        else
        {
            if([SCFileManager exist:outPut])
            {
                [SCFileManager deleteFileWithURL:outPut];
            }
            return nil;
        }
    }
    
    return nil;
}

- (SCVideoComposition*)convertToVideoComposition:(BOOL)forExport withDir:(NSURL*)dir
{
    if(self.image)
    {
        NSURL *outPut = [SCFileManager createIncreaseNameFromDir:dir withName:self.name andtype:SC_MOV];
        UIImage * neededImage;
        if(self.filterComposition.filterMode == SCImageFilterModeNormal)
        {
            neededImage = self.image;
        }
        else
        {
            neededImage = self.filterComposition.filteredImage;
        }
        //check to create video with text
        if(forExport)
        {
            if(self.texts.count > 0)
            {
                //draw text to image here to write final video for composition
                CGSize previewSize;
                
                previewSize = SC_IS_IPHONE5 ? SC_PREVIEW_4INCH_SIZE:SC_PREVIEW_3INCH5_SIZE;
                self.imageWithText = [SCImageUtil imageTextWithSlideComposition:self previewSize:previewSize];
                if([SCSlideShowSettingManager getInstance].transitionsEnabled)
                    [SCVideoUtil createVideoWith:self output:outPut FPS:SC_VIDEO_VINE_RENDER_FPS];
                else
                    [SCVideoUtil createStandardVideoWith:self.imageWithText size:SC_VIDEO_SIZE time:CMTimeGetSeconds(self.duration) output:outPut FPS:SC_VIDEO_VINE_RENDER_FPS];

            }
            //create video item with output format
            else
            {
                if([SCSlideShowSettingManager getInstance].transitionsEnabled)
                    [SCVideoUtil createStandardVideoWith:neededImage size:SC_VIDEO_SIZE time:CMTimeGetSeconds(self.duration) output:outPut FPS:SC_VIDEO_VINE_RENDER_FPS];
                else
                    [SCVideoUtil createStandardVideoWith:neededImage size:SC_VIDEO_SIZE time:CMTimeGetSeconds(self.duration) output:outPut FPS:SC_VIDEO_VINE_RENDER_FPS];
            }
            
        }
        else
        {
            //create video item with compose format
            [SCVideoUtil createVideoWith:neededImage size:SC_VIDEO_SIZE time:CMTimeGetSeconds(self.duration) output:outPut];
            
        }
    
        SCVideoComposition *videoItem = [[SCVideoComposition alloc]initWithURL:outPut];
        if(CMTimeGetSeconds(videoItem.duration) > 0)
        {
            videoItem.startTimeInTimeline    = self.startTimeInTimeline;
            videoItem.timeRange              = self.timeRange;
            videoItem.startTransition        = self.startTransition;
            videoItem.endTransition          = self.endTransition;
            return  videoItem;
        }
        else
        {
            if([SCFileManager exist:outPut])
            {
                [SCFileManager deleteFileWithURL:outPut];
            }
            return nil;
        }
    }
    
    return nil;
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
	if (self.endTransition && self.endTransition.type != SCVideoTransitionTypeNone)
    {
		CMTime beginTransitionTime = CMTimeSubtract(self.timeRange.duration, self.endTransition.duration);
		return CMTimeRangeMake(beginTransitionTime, self.endTransition.duration);
	}
	return CMTimeRangeMake(self.timeRange.duration, kCMTimeZero);
}

- (NSString *)mediaType {
	// This is actually muxed, but treat as video for our purposes
	return AVMediaTypeVideo;
}

#pragma mark - clear data

- (void)clearAll
{
    [super clearAll];
    self.model = nil;
    self.image = nil;
    self.thumbnailImage = nil;
    self.assetURL = nil;
    self.startTransition = nil;
    self.endTransition = nil;
    self.originalImage = nil;
    self.assetURL = nil;
    
    if(self.texts.count > 0)
    {
        for(SCTextComposition *text in self.texts)
        {
            [text clearAll];
        }
        [self.texts removeAllObjects];
        self.texts = nil;
    }
    
    [self.filterComposition clearAll];
    self.filterComposition = nil;
    
    
}


@end
