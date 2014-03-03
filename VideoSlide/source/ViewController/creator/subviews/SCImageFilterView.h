//
//  SCImageFilterView.h
//  SlideshowCreator
//
//  Created 10/14/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCView.h"
#import "SCSlideComposition.h"

@protocol  SCImageFilterViewProtocol <NSObject>

- (void)didFinishSettingFilterWithChanged:(BOOL)changed;
- (void)didSelectedFilterOnSlideComposition:(SCSlideComposition*)slideComposition;

@end

@interface SCImageFilterView : SCView

@property (nonatomic, strong) IBOutlet UIImageView *photoImgView;
@property (nonatomic, weak)  id<SCImageFilterViewProtocol> delegate;

- (void)updateWith:(SCSlideComposition*)slide;
- (void)hidePreviewfilterImageWith:(void (^)(void))completionBlock;;

@end
