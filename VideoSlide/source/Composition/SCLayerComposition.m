//
//  SCLayerComposition.m
//  SlideshowCreator
//
//  Created 9/27/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCLayerComposition.h"
#import <CoreText/CoreText.h>
@implementation SCLayerComposition

- (CALayer *)layer {
    
	CALayer *titleLayer = [CALayer layer];
	titleLayer.bounds = CGRectMake(0, 0, 1280, 400);
    
	if (self.titleImage) {
		CALayer *imageLayer = [CALayer layer];
		UIImage *logoImage = self.titleImage;
		imageLayer.bounds = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
		imageLayer.position = CGPointMake(CGRectGetMidX(titleLayer.bounds) - 20.0f, 100);
		imageLayer.contents = (id) logoImage.CGImage;
		[titleLayer addSublayer:imageLayer];
	}
    
	CGFloat fontSize = self.useLargeFont ? 64.0f : 54.0f;
	CATextLayer *titleTextLayer = [CATextLayer layer];
	titleTextLayer.string = self.titleText;
	CTFontRef fontRef = CTFontCreateWithName((CFStringRef) @"GillSans-Bold", fontSize, NULL);
	titleTextLayer.font = fontRef;
	titleTextLayer.fontSize = fontSize;
	CFRelease(fontRef);
	UIFont *font = [UIFont fontWithName:@"GillSans-Bold" size:fontSize];
	CGSize textSize = [self.titleText sizeWithFont:font];
	titleTextLayer.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
	titleTextLayer.position = CGPointMake(CGRectGetMidX(titleLayer.bounds), 300);
	titleTextLayer.backgroundColor = [UIColor clearColor].CGColor;
    
	[titleLayer addSublayer:titleTextLayer];
    
	titleLayer.opacity = 0.0f;
    
	// TODO: Switch to keyframe animation
	
	CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeInAnimation.fromValue = @0.0f;
	fadeInAnimation.toValue = @1.0f;
	fadeInAnimation.additive = NO;
	fadeInAnimation.removedOnCompletion = NO;
	fadeInAnimation.beginTime = CMTimeGetSeconds(self.startTimeInTimeline);
	fadeInAnimation.duration = 1.0;
	fadeInAnimation.autoreverses = NO;
    
	fadeInAnimation.fillMode = kCAFillModeBoth;
    
	[titleLayer addAnimation:fadeInAnimation forKey:nil];
    
	CABasicAnimation *outAnimation;
	CMTime animatedOutStartTime = CMTimeAdd(self.startTimeInTimeline, self.timeRange.duration);
    
	if (!self.spinOut) {
		outAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		outAnimation.fromValue = @1.0f;
		outAnimation.toValue = @0.0f;
		outAnimation.additive = NO;
		outAnimation.removedOnCompletion = NO;
		outAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime);
		outAnimation.duration = 1.0;
		outAnimation.autoreverses = NO;
		outAnimation.fillMode = kCAFillModeForwards;
		[titleLayer addAnimation:outAnimation forKey:nil];
		
	} else {
        
		CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
		rotationAnimation.toValue = @((2 * M_PI) * -2); // 3 is the number of 360 degree rotations
		// Make the rotation animation duration slightly less than the other animations to give it the feel
		// that it pauses at its largest scale value
		rotationAnimation.duration = 3.0f;
		rotationAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime);
		rotationAnimation.removedOnCompletion = NO;
		rotationAnimation.autoreverses = NO;
		rotationAnimation.fillMode = kCAFillModeForwards;
		rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
		CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		scaleAnimation.fromValue = @1.0f;
		scaleAnimation.toValue = @0.0f;
		scaleAnimation.duration = 0.8f;
		scaleAnimation.removedOnCompletion = NO;
		scaleAnimation.fillMode = kCAFillModeForwards;
		scaleAnimation.autoreverses = NO;
		scaleAnimation.beginTime = CMTimeGetSeconds(animatedOutStartTime);
		scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
		CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
		//animationGroup.duration = 1.0f;
		animationGroup.removedOnCompletion = NO;
		animationGroup.fillMode = kCAFillModeForwards;
		animationGroup.autoreverses = NO;
		animationGroup.beginTime = CMTimeGetSeconds(animatedOutStartTime);
		animationGroup.animations = @[rotationAnimation, scaleAnimation];
        
		[titleLayer addAnimation:rotationAnimation forKey:@"spinOut"];
		[titleLayer addAnimation:scaleAnimation forKey:@"scaleOut"];
        
	}
    
	return titleLayer;
    
}

@end

