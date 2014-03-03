//
//  Created 9/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//


#import "UIView+SCAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (SCAdditions)

#pragma mark - Geometry Methods

- (CGFloat)frameX {
	return self.frame.origin.x;
}

- (void)setFrameX:(CGFloat)newX {
	self.frame = CGRectMake(newX, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)frameY {
	return self.frame.origin.y;
}

- (void)setFrameY:(CGFloat)newY {
	self.frame = CGRectMake(self.frame.origin.x, newY, self.frame.size.width, self.frame.size.height);
}

- (CGFloat)frameWidth {
	return self.frame.size.width;
}

- (void)setFrameWidth:(CGFloat)newWidth {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height);
}

- (CGFloat)frameHeight {
	return self.frame.size.height;
}

- (void)setFrameHeight:(CGFloat)newHeight {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
}

- (CGPoint)frameOrigin {
	return self.frame.origin;
}

- (void)setFrameOrigin:(CGPoint)newOrigin {
	self.frame = CGRectMake(newOrigin.x, newOrigin.y, self.frame.size.width, self.frame.size.height);
}

- (CGSize)frameSize {
	return self.frame.size;
}

- (void)setFrameSize:(CGSize)newSize {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newSize.width, newSize.height);
}

- (CGFloat)boundsX {
	return self.bounds.origin.x;
}

- (void)setBoundsX:(CGFloat)newX {
	self.bounds = CGRectMake(newX, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
}

- (CGFloat)boundsY {
	return self.bounds.origin.y;
}

- (void)setBoundsY:(CGFloat)newY {
	self.bounds = CGRectMake(self.bounds.origin.x, newY, self.bounds.size.width, self.bounds.size.height);
}

- (CGFloat)boundsWidth {
	return self.bounds.size.width;
}

- (void)setBoundsWidth:(CGFloat)newWidth {
	self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, newWidth, self.bounds.size.height);
}

- (CGFloat)boundsHeight {
	return self.bounds.size.height;
}

- (void)setBoundsHeight:(CGFloat)newHeight {
	self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, newHeight);
}

- (CGFloat)centerX {
	return self.center.x;
}

- (void)setCenterX:(CGFloat)newX {
	self.center = CGPointMake(newX, self.center.y);
}

- (CGFloat)centerY {
	return self.center.y;
}

- (void)setCenterY:(CGFloat)newY {
	self.center = CGPointMake(self.center.x, newY);
}

#pragma mark - Screen Shotting Methods

- (UIImage *)toImage {
	return [self toImageWithSize:self.bounds.size];
}

- (UIImage *)toImageWithSize:(CGSize)size {
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (UIImageView *)toImageView {
	return [self toImageViewWithSize:self.bounds.size];
}

- (UIImageView *)toImageViewWithSize:(CGSize)size {
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[self toImageWithSize:size]];
	imageView.frame = CGRectMake(self.frameX, self.frameY, size.width, size.height);
	return imageView;
}

@end
