//
//  SCProjectExporter.m
//  SlideshowCreator
//
//  Created 9/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCProjectExporter.h"

@implementation SCProjectExporter

@synthesize delegate = _delegate;


- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    
    return self;
}


- (void)exportProjectWithSlideShow:(SCSlideShowComposition *)slideShow
{
    if(slideShow.model)
    {
        __block BOOL exportStatus = NO;
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            //
            exportStatus = [slideShow exportResourcesToProject];
            //refresh project directory
            [[SCFileManager getInstance] updateSlideShows];
            dispatch_async( dispatch_get_main_queue(), ^{
                // Add code here to update the UI/send notifications based on the
                // results of the background processing
                if([self.delegate respondsToSelector:@selector(didFinishExportProjectWithSatus:)])
                {
                    [self.delegate didFinishExportProjectWithSatus:exportStatus];
                }

            });
        });
    }
    
    

    
}


@end
