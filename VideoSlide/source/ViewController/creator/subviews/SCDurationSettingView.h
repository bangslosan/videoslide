//
//  SCDurationSettingView.h
//  SlideshowCreator
//
//  Created 10/17/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"

@protocol SCDurationSettingViewProtocol <NSObject>

- (void)didFinishSetting:(BOOL)hasChanged;

@end

@interface SCDurationSettingView : SCView

@property (nonatomic, weak) id<SCDurationSettingViewProtocol> delegate;


- (void)updateWithSlideShowSetting;

@end
