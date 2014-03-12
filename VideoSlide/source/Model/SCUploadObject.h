//
//  SCUploadObject.h
//  SlideshowCreator
//
//  Created 10/29/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SCUploadObjectDelegate <NSObject>
@optional
- (void)onUpdateUploadProgress:(float)progress;
- (void)onUpdateUploadProgressWithSegment:(float)segment;
- (void)onUpdateUploadStatus:(SCUploadStatus)uploadStatus;
@end

@interface SCUploadObject : SCModel

@property (nonatomic,weak) id <SCUploadObjectDelegate> delegate;
@property (nonatomic,strong) NSString           *fileName;
@property (nonatomic,assign) SCUploadType       uploadType;
@property (nonatomic,assign) SCUploadStatus     uploadStatus;
@property (atomic)           float              uploadProgress;

@property (nonatomic,strong) NSURL              *videoURL;
@property (nonatomic,strong) NSDate             *uploadDate;

// upload process
@property (nonatomic,strong) NSURL                        *_uploadLocationURL;  // URL for restarting an upload.

// connection rate for fb
@property (nonatomic,strong) NSTimer                      *connectionRateTimer;
@property (nonatomic,assign) int                          currentTotalBytes;
@property (nonatomic,assign) float                        currentProgressSegmentUpdated;
@property (nonatomic,assign) float                        fSegmentProgress;

// vine
@property (nonatomic,strong) NSString           *vineUploadVideoURL; // upload video success => return http path
@property (nonatomic,strong) NSString           *vineUploadThumbnailURL; // upload thumbnail success => return http path

@property (nonatomic,strong) UIImage            *vineThumbnailImage;
@property (nonatomic,strong) NSURL              *vineOutputURL;

- (id)init;
- (void)upload; // youtube
- (void)facebookUpload;
- (void)sartUploadCurrentVideo;

@end
