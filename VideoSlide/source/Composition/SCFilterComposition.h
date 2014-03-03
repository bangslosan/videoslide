//
//  SCFilterComposition.h
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCFilterModel.h"

@interface SCFilterComposition : SCComposition
@property (nonatomic, strong)SCFilterModel *model;
@property (nonatomic,strong) UIImage            *filteredImage;
@property (nonatomic,strong) UIImage            *thumbnailFilteredImage;
@property (nonatomic,assign) SCImageFilterMode  filterMode;
@property (nonatomic,assign) BOOL               hasFilterChanged;
@end
