//
//  SCVideoUtil.h
//  SlideshowCreator
//
//  Created 9/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCVideoComposition.h"
#import "SCSlideComposition.h"
#import "SCSlideShowComposition.h"

@interface SCVideoUtil : NSObject


/*
 *Create a video composition from a slide compostiion, time and output File URL
 *
 */

+ (void)createVideoWith:(SCSlideComposition *)slide output:(NSURL *)output FPS:(float)FPS;


/*
 *Create a video composition from an image with size, time and output File URL
 *
 */

+ (void)createVideoWith:(UIImage*)backgroundImg  size:(CGSize)size time:(float)time output:(NSURL*)output;

/*
 *Create a standard video composition for export video from an image with size, time and output File URL
 *
 */


+ (void)createStandardVideoWith:(UIImage*)backgroundImg  size:(CGSize)size time:(float)time output:(NSURL*)output FPS:(float)FPS;

/*
 *Create a video composition from an array of images with size, time and output File URL
 *
 */


+ (void)createVideoWithArrayImages:(NSMutableArray*)images  size:(CGSize)size time:(float)time output:(NSURL*)output;

/*
 *Create a video composition from a slide show  with size, time and output File URL
 *
 */


+ (void)createVideoWithSlideShow:(SCSlideShowComposition*)slideShow output:(NSURL*)output;;


/*
 *Get core video Buffer from CGImage and size
 *
 */

+ (CVPixelBufferRef)videoPixelBufferFromCGImage: (CGImageRef) image andSize:(CGSize) size;


/*
 *Resize video
 **/

+ (void)resizeVideoWith:(NSURL*)source des:(NSURL*)des;



@end
