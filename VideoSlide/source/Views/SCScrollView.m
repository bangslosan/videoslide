//
//  SCScrollView.m
//  SlideshowCreator
//
//  Created 12/18/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCScrollView.h"

@implementation SCScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    
    if ([view isKindOfClass:[UIButton class]]) {//or whatever class you want to override
        return YES;
    }
    
    if ([view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    
    return YES;
}

@end
