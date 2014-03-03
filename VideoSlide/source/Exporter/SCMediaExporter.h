//
//  SCMediaExporter.h
//  SlideshowCreator
//
//  Created 9/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCMediaExporterProtocol <NSObject>

@optional

- (void)didFinishExportVideoWithSuccess:(BOOL)status;
- (void)didStartExportVideo;
- (void)percentOfExportProgress:(float)percent;
- (void)didFinishPreExportWithSuccess:(BOOL)status;
- (void)didFinishWriteToLibraryWithSuccess:(BOOL)status;

@end

@interface SCMediaExporter : SCExporter

@property (nonatomic, strong)        NSString  *mediaExportQuality;
@property (nonatomic, assign)        BOOL  needToWriteToCameraRoll;
@property (nonatomic, weak)          id<SCMediaExporterProtocol> delegate;

- (void)exportMediaWithSlideShow:(SCSlideShowComposition*)slideShow;


@end
