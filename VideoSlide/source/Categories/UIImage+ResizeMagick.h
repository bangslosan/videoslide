//
//  UIImage+ResizeMagick.h
//  Created 9/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//



@interface UIImage (ResizeMagick)

- (UIImage *) resizedImageByMagick: (NSString *) spec;
- (UIImage *) resizedImageByWidth:  (NSUInteger) width;
- (UIImage *) resizedImageByHeight: (NSUInteger) height;
- (UIImage *) resizedImageWithMaximumSize: (CGSize) size;
- (UIImage *) resizedImageWithMinimumSize: (CGSize) size;
- (UIImage *) resizeAndCropImageWith:(CGSize)size;
- (UIImage*) croppedImageWithRect: (CGRect) rect;
- (UIImage*)crop:(CGRect)rect;

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
