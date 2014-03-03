//
//  SCTextModel.h
//  SlideshowCreator
//
//  Created 9/12/13.
//  Copyright (c) 2013 Doremon. All rights reserved.
//

#import "SCCompositionModel.h"


@interface SCTextModel : SCCompositionModel

@property (nonatomic, strong)  NSString             *text;
@property (nonatomic, strong)  NSString             *fontName;

@property (nonatomic)          SCVector             position;
@property (nonatomic)          SCVector             center;
@property (nonatomic)          SCSize               size;
@property (nonatomic)          SCColor              color;

@property (nonatomic)          int                  fontSize;
@property (nonatomic)          int                  lineSpacing;
@property (nonatomic)          int                  characterSpacing;
@property (nonatomic)          float                opacity;
@property (nonatomic)          int                  angle;

@property (nonatomic)          SCTextAlignment      txtAlignment;

@property (nonatomic)          ColorPickerText      indexColorPickerText;


- (id)initWithTextModel:(SCTextModel*)textModel;

@end
