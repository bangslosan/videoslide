//
//  Created 9/6/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

@interface UIView (SCAdditions)

@property (nonatomic, assign) CGFloat frameX;
@property (nonatomic, assign) CGFloat frameY;
@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, assign) CGFloat frameHeight;
@property (nonatomic, assign) CGPoint frameOrigin;
@property (nonatomic, assign) CGSize frameSize;

@property (nonatomic, assign) CGFloat boundsX;
@property (nonatomic, assign) CGFloat boundsY;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

/**
 * Returns the UIImage representation of this view.
 */
- (UIImage *)toImage;

/**
 * Returns a UIImageView representation of this view.  The image view's initial frame
 * is set to the frame as the view.
 */
- (UIImageView *)toImageView;

@end
