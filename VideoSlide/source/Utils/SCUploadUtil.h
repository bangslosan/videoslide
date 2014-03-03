//
//  SCUploadUtil.h
//  SlideshowCreator
//
//  Created 11/4/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCUploadUtil : NSObject

+ (NSString*)uploadStatusString:(SCUploadStatus)status;
+ (NSString*)imageUploadType:(SCUploadType)uploadType;
+ (NSString*)imageUploadStatus:(SCUploadStatus)uploadStatus;
+ (UIColor*)colorUploadStatus:(SCUploadStatus)uploadStatus;
+ (BOOL)isUploadDuplicated:(SCUploadObject*)uploadObject uploadType:(SCUploadType)uploadType;
@end
