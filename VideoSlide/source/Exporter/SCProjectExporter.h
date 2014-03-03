//
//  SCProjectExporter.h
//  SlideshowCreator
//
//  Created 9/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SCProjectExporterProtocol <NSObject>

- (void)didFinishExportProjectWithSatus:(BOOL)status;

@end

@interface SCProjectExporter : SCExporter

@property (nonatomic, weak) id<SCProjectExporterProtocol> delegate;

- (void)exportProjectWithSlideShow:(SCSlideShowComposition*)slideShow;


@end
