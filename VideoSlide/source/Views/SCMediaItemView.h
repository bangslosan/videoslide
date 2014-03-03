//
//  SCMediaItemView.h
//  SlideshowCreator
//
//  Created 12/3/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"

@interface SCMediaItemView : SCView

@property (nonatomic)          CGPoint            lastPosition;
@property (nonatomic)          BOOL                isSelected;
@property (nonatomic)          BOOL                isMoving;
@property (nonatomic)          BOOL                markDelete;


- (void)updateWithGesture:(UIGestureRecognizer*)gesture;
- (void)beginWithGesture:(UIGestureRecognizer*)gesture zoom:(BOOL)zoom moveUp:(BOOL)moveUp completion:(void (^)(void))completion;
- (void)endWithGesture:(UIGestureRecognizer*)gesture completion:(void (^)(void))completion;


- (void)showDeleteWarning;
- (void)hideDeleteWarning;
- (void)deleteAnimation;

@end
